PL/SQL Developer Test script 3.0
390
declare
  TYPE typ_tab_linha IS VARRAY(8) OF VARCHAR2(5000);

  TYPE vr_reg_texto is record(
    dsdchave varchar2(30),
    dsdtexto varchar2(5000));

  TYPE vr_typ_texto IS TABLE OF vr_reg_texto INDEX BY pls_integer;

  vr_tab_linha typ_tab_linha := typ_tab_linha(NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL);

  vr_exc_saida EXCEPTION;

  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  --Tabela de Erros
  vr_tab_erro gene0001.typ_tab_erro;

  --Variaveis para retorno de erro
  vr_des_erro     VARCHAR2(3);
  vr_cdcritic     INTEGER := 0;
  vr_dscritic     VARCHAR2(4000);
  vr_tab_nmclob   VARCHAR2(4000);
  vr_tab_contlinh INTEGER := 0;
  vr_qtdlinha        INTEGER;

  vr_des_xml8         CLOB;
  vr_caminho          VARCHAR2(1000);
  vr_setlinha         VARCHAR2(5000);
  vr_dtatual          DATE;
  vr_dtmvtolt         VARCHAR2(10);
  vr_dtmvtopr         VARCHAR2(10);
  vr_dtmvtlt2         VARCHAR2(10);
  vr_tempoatu         VARCHAR2(1000);
  vr_tparquiv         VARCHAR2(1000);
  vr_des_txt8         VARCHAR2(32767);
  vr_tab_texto8       vr_typ_texto;
  vr_tab_texto_Generi vr_typ_texto;

  -- Selecionar todas Cooperativas para o processamento
  CURSOR cr_crapcop(pr_cdcoppar crapcop.cdcooper%TYPE DEFAULT 0,
                    pr_cdprogra tbgen_batch_controle.cdprogra%TYPE DEFAULT 0,
                    pr_qterro   number DEFAULT 0,
                    pr_dtmvtolt tbgen_batch_controle.dtmvtolt%TYPE DEFAULT NULL) IS
    SELECT cop.cdcooper,
           cop.nmrescop,
           cop.nrtelura,
           cop.cdbcoctl,
           cop.cdagectl,
           cop.dsdircop,
           cop.nrctactl,
           cop.cdagedbb,
           cop.cdageitg,
           cop.nrdocnpj
      FROM crapcop cop
     WHERE cop.cdcooper <> 3
       AND cop.cdcooper = decode(pr_cdcoppar, 0, cop.cdcooper, pr_cdcoppar)
       AND cop.flgativo = 1
       AND (pr_qterro = 0 or
           (pr_qterro > 0 and exists
            (select 1
                from tbgen_batch_controle
               where tbgen_batch_controle.cdcooper = :pr_cdcooper -- Controle é gravado com a Coop Central
                 and tbgen_batch_controle.cdprogra = :pr_cdprogra
                 and tbgen_batch_controle.tpagrupador = 3
                    -- Somente possibilidades de agencia desta Coop
                 AND tbgen_batch_controle.cdagrupador BETWEEN
                     (lpad(cop.cdcooper, 3, '0') || '00000') AND
                     (lpad(cop.cdcooper, 3, '0') || '99999')
                 and tbgen_batch_controle.insituacao = 1
                 and tbgen_batch_controle.dtmvtolt = pr_dtmvtolt)))
     ORDER BY cop.cdcooper;

  PROCEDURE pc_monta_linha(pr_text    in varchar2,
                           pr_nrposic in integer,
                           pr_arquivo in integer) IS
    vr_linha       varchar2(5000) := null;
    vr_tam_linha   integer;
    vr_qtd_brancos integer;
  BEGIN
    vr_linha := vr_tab_linha(pr_arquivo);
    -- Verifica quantos caracteres já existem na linha
    vr_tam_linha := nvl(length(vr_linha), 0);
    -- Calcula quantidade de espaços a incluir na linha
    vr_qtd_brancos := pr_nrposic - vr_tam_linha - 1;
    -- Concatena os espaços em branco e o novo texto
    vr_linha := vr_linha || rpad(' ', vr_qtd_brancos, ' ') || pr_text;
    -- Modificar vetor com a linha atualizada
    vr_tab_linha(pr_arquivo) := gene0007.fn_caract_acento(GENE0007.fn_caract_acento(vr_linha,
                                                                                    0),
                                                          1,
                                                          '`´#$&%¹²³ªº°*!?<>/\|',
                                                          '                    ');
  END pc_monta_linha;

  PROCEDURE pc_escreve_clob(pr_des_text IN VARCHAR2,
                            pr_cod_info IN INTEGER,
                            pr_flfechar IN BOOLEAN DEFAULT FALSE) IS -- Identifica se deve fechar o CLOB
  BEGIN
       -- Escrever no arquivo XML
       CASE pr_cod_info
         WHEN 8 THEN gene0002.pc_escreve_xml(vr_des_xml8,vr_des_txt8,pr_des_text,pr_flfechar);
       END CASE;
     EXCEPTION
       WHEN OTHERS THEN
         vr_cdcritic:= 0;
         vr_dscritic:= 'Erro ao escrever no CLOB('||pr_cod_info||') --> '||sqlerrm;
         -- Levantar Excecao
         RAISE vr_exc_saida;

  END pc_escreve_clob;

  PROCEDURE pc_escreve_dado(pr_des_text IN VARCHAR2,
                            pr_cod_info IN INTEGER,
                            pr_des_chav IN VARCHAR2) IS
    vr_count number;
    vr_linha VARCHAR2(5000);
  BEGIN
    -- Se foi passada infomacao
    IF pr_des_text IS NOT NULL THEN
      -- Atribuir o parametro para a variavel
      vr_linha := pr_des_text;
    ELSE
      -- Enviar para a pltable o conteudo da tab_linha
      vr_linha := vr_tab_linha(pr_cod_info);
      -- Limpar string
      vr_tab_linha(pr_cod_info) := NULL;
    END IF;
  
    -- Enviar para a tabela de memória correspondente o char montado acima
    IF pr_cod_info = 8 THEN
      vr_count := vr_tab_texto8.count();
      vr_tab_texto8(vr_count).dsdchave := pr_des_chav;
      vr_tab_texto8(vr_count).dsdtexto := vr_linha;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao escrever na PLTABLE(' || pr_cod_info || '). ' ||
                     sqlerrm;
      --Levantar Excecao
      RAISE vr_exc_saida;
    
  END pc_escreve_dado;

  --Procedure para Pagamentos de Acordos
  PROCEDURE pc_gera_carga_pagto_acordo(pr_idarquivo IN INTEGER,
                                       pr_cdcooper  IN crapcop.cdcooper%TYPE,
                                       pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,
                                       pr_cdcritic  OUT INTEGER,
                                       pr_dscritic  OUT VARCHAR2) IS
  BEGIN
    DECLARE
    
      --Selecionar Pagamentos de Acordos
      CURSOR cr_crapret(pr_cdcooper IN crapcop.cdcooper%type,
                        pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                        pr_nrcnvcob IN crapret.nrcnvcob%TYPE) IS
      
        SELECT tbrecup_acordo.nracordo,
               tbrecup_acordo_parcela.nrparcela,
               crapcob.nrnosnum,
               crapoco.dsocorre,
               crapret.vlrpagto,
               crapret.dtocorre,
               crapcob.vltitulo
          FROM crapret
          JOIN crapcco
            ON crapcco.cdcooper = crapret.cdcooper
           AND crapcco.nrconven = crapret.nrcnvcob
          JOIN crapcob
            ON crapcob.cdcooper = crapret.cdcooper
           AND crapcob.nrcnvcob = crapret.nrcnvcob
           AND crapcob.nrdconta = crapret.nrdconta
           AND crapcob.nrdocmto = crapret.nrdocmto
           AND crapcob.nrdctabb = crapcco.nrdctabb
           AND crapcob.cdbandoc = crapcco.cddbanco
          JOIN crapoco
            ON crapoco.cdcooper = crapcob.cdcooper
           AND crapoco.cddbanco = crapcob.cdbandoc
           AND crapoco.cdocorre = crapret.cdocorre
           AND crapoco.tpocorre = 2
          JOIN tbrecup_acordo_parcela
            ON tbrecup_acordo_parcela.nrboleto = crapcob.nrdocmto
           AND tbrecup_acordo_parcela.nrconvenio = crapcob.nrcnvcob
           AND tbrecup_acordo_parcela.nrdconta_cob = crapcob.nrdconta
          JOIN tbrecup_acordo
            ON tbrecup_acordo.nracordo = tbrecup_acordo_parcela.nracordo
         WHERE crapret.cdcooper = pr_cdcooper
           AND crapret.nrcnvcob = pr_nrcnvcob
           AND crapret.dtocorre = pr_dtmvtolt
           AND crapret.dtocorre BETWEEN '28/12/2018' AND '30/12/2018'
           AND tbrecup_acordo.dtcancela IS NULL
           AND crapret.cdocorre IN (6, 76); -- liquidacao normal COO/CEE
    
      vr_nrcnvcob crapprm.dsvlrprm%TYPE;
    
    BEGIN
      --Limpar parametros erro
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
    
      -- Localizar convenio de cobrança
      vr_nrcnvcob := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper,
                                               pr_nmsistem => 'CRED',
                                               pr_cdacesso => 'ACORDO_NRCONVEN');
    
      FOR rw_crapret IN cr_crapret(pr_cdcooper => pr_cdcooper -- Cooperativa
                                  ,
                                   pr_dtmvtolt => pr_dtmvtolt -- Data Movimento
                                  ,
                                   pr_nrcnvcob => vr_nrcnvcob) LOOP
        -- Numero do Convenio
      
        pc_monta_linha(RPAD('', 3, ' '), 1, pr_idarquivo); -- Tipo de Registro 
        pc_monta_linha(RPAD(rw_crapret.nrnosnum, 20, ' '), 4, pr_idarquivo); -- Nosso Numero
        pc_monta_linha(GENE0002.fn_mask(rw_crapret.nracordo,
                                        '9999999999999'),
                       24,
                       pr_idarquivo); -- Número do Acordo
        pc_monta_linha(GENE0002.fn_mask(rw_crapret.nrparcela, '99999'),
                       37,
                       pr_idarquivo); -- Número da Parcela do Acordo
        pc_monta_linha(RPAD(rw_crapret.dsocorre, 2, ' '), 42, pr_idarquivo); -- Identificacao de Ocorrencia           
        pc_monta_linha(GENE0002.fn_mask(rw_crapret.vlrpagto * 100,
                                        '999999999999999'),
                       44,
                       pr_idarquivo); -- Valor pago
        pc_monta_linha(GENE0002.fn_mask(rw_crapret.vltitulo * 100,
                                        '999999999999999'),
                       59,
                       pr_idarquivo); -- Valor do Boleto
        pc_monta_linha(RPAD(TO_CHAR(rw_crapret.dtocorre, 'MMDDYYYY'),
                            8,
                            ' '),
                       74,
                       pr_idarquivo); -- Data de entrada de pagamento
        pc_monta_linha(RPAD(TO_CHAR(rw_crapret.dtocorre, 'MMDDYYYY'),
                            8,
                            ' '),
                       82,
                       pr_idarquivo); -- Data de Transacao
        pc_monta_linha(RPAD('Acordo:' ||
                            GENE0002.fn_mask(rw_crapret.nracordo,
                                             '9999999999999') ||
                            ', Parcela:' ||
                            GENE0002.fn_mask(rw_crapret.nrparcela, '99999'),
                            100,
                            ' '),
                       90,
                       pr_idarquivo); -- Descrição do Pagamento                                 
        --Escrever no arquivo
        pc_escreve_dado(NULL, pr_idarquivo, null);
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina pc_crps652.pc_gera_carga_pagto_acordo. ' ||
                       SQLERRM;
    END;
  END pc_gera_carga_pagto_acordo;

begin
  vr_tab_texto8.delete;
  vr_tab_texto_Generi.delete;
  
  dbms_lob.createtemporary(vr_des_xml8, TRUE);
  dbms_lob.open(vr_des_xml8, dbms_lob.lob_readwrite);

  -- Verifica se a data esta cadastrada
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => :pr_cdcooper);
  FETCH BTCH0001.cr_crapdat
    INTO rw_crapdat;
  -- Se nao encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois havera raise
    CLOSE BTCH0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;
  END IF;

--  BTCH0001.rw_crapdat.dtmvtolt := '20/12/2018';
--  BTCH0001.rw_crapdat.dtmvtoan := '19/12/2018';
--  BTCH0001.rw_crapdat.dtmvtopr := '21/12/2018';

  rw_crapdat.dtmvtolt := '31/12/2018';
  rw_crapdat.dtmvtoan := '28/12/2018';
  rw_crapdat.dtmvtopr := '02/01/2019';

  -- Se estiver rodando pós processo 
  IF rw_crapdat.inproces = 1 THEN
    vr_dtatual  := rw_crapdat.dtmvtoan;
    vr_dtmvtopr := TO_CHAR(rw_crapdat.dtmvtolt, 'YYYYMMDD');
  ELSE
    vr_dtatual  := rw_crapdat.dtmvtolt;
    vr_dtmvtopr := TO_CHAR(rw_crapdat.dtmvtopr, 'YYYYMMDD');
  END IF;

  -- Data Movimento
  vr_dtmvtolt := TO_CHAR(vr_dtatual, 'YYYYMMDD');
  vr_dtmvtlt2 := TO_CHAR(vr_dtatual, 'MMDDYYYY');
  vr_tempoatu := TO_CHAR(SYSDATE, 'HH24MISS');

  vr_caminho    := gene0001.fn_param_sistema('CRED',
                                             :pr_cdcooper,
                                             'CRPS652_CYBER_ENVIA');
  vr_setlinha   := vr_caminho || vr_dtmvtolt || '_' || vr_tempoatu;
  vr_setlinha   := vr_setlinha || '_pagboleto_in.txt';
  vr_tparquiv   := 'acordo';
  vr_tab_nmclob := vr_setlinha;
  vr_setlinha   := rpad('H', 3, ' ') || RPAD('AYLLOS', 15, ' ') ||
                   rpad('CYBER', 15, ' ') || RPAD(vr_tparquiv, 10, ' ') ||
                   rpad('00000000', 8, ' ') || rpad(vr_dtmvtolt, 8, ' ') ||
                   chr(10);

  -- Escrever Header no CLOB
  pc_escreve_clob(vr_setlinha, 8);
  
  FOR rw_crapcop IN cr_crapcop LOOP
  
    pc_gera_carga_pagto_acordo(pr_idarquivo => 8 /*str_8*/ --Id do arquivo
                              ,
                               pr_cdcooper  => rw_crapcop.cdcooper --Cooperativa
                              ,
                               pr_dtmvtolt  => vr_dtatual --Data de Movimentac         
                              ,
                               pr_cdcritic  => vr_cdcritic --Codigo Erro
                              ,
                               pr_dscritic  => vr_dscritic); --Descricao erro
  
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
  end loop;

  vr_tab_texto_Generi := vr_tab_texto8;

  -- Guardar quantidade de linhas
  vr_tab_contlinh := vr_tab_texto_Generi.count();

  -- Efetuar laço para ler todos os registros da pltable e transportar ao CLOB
  FOR idx2 IN 0 .. vr_tab_texto_Generi.count() - 1 LOOP
    -- Somente no ultimo, pode ser que o mesmo esteja vazio devido a quebra prevendo 
    -- o reposicionamento na proxima linha, neste caso então não enviamos nada
    IF idx2 != vr_tab_texto_Generi.last OR
       trim(vr_tab_texto_Generi(idx2).dsdtexto) IS NOT NULL THEN
      pc_escreve_clob(vr_tab_texto_Generi(idx2).dsdtexto || chr(10), 8);
    END IF;
  END LOOP;
  
  vr_qtdlinha:= vr_tab_texto_Generi.count() + 2;
  -- Montar Linha
  vr_setlinha:= RPad('T',3,' ')||gene0002.fn_mask(vr_qtdlinha,'9999999')||chr(10);
  -- Escrever linha no arquivo e finaliza varchar2 temporária para o CLOB
  pc_escreve_clob(vr_setlinha,8,TRUE);

  gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml8,
                                pr_caminho  => vr_caminho,
                                pr_arquivo  => vr_tab_nmclob,
                                pr_des_erro => vr_dscritic);
  dbms_lob.close(vr_des_xml8);
  dbms_lob.freetemporary(vr_des_xml8);
  ROLLBACK;
EXCEPTION
  WHEN vr_exc_saida THEN
    -- Buscar a descricao
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
    -- Efetuar rollback
    ROLLBACK;
    RAISE;
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
end;
2
pr_cdcooper
1
3
5
pr_cdprogra
1
OSCAR
5
4
      DBMS_XSLPROCESSOR.CLOB2FILE(pr_clob, pr_caminho, vr_nom_arquiv, NLS_CHARSET_ID('UTF8'));

vr_nom_arquiv
vr_sqlcode
