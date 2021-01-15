PL/SQL Developer Test script 3.0
370
-- Created on 03/07/2020 by T0032613 
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
      
  vr_nomdojob  CONSTANT VARCHAR2(100) := 'jbcrd_bancoob_envia_deb_fat';
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
      
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
     WHERE cop.cdcooper = 3;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca listagem das cooperativas
  CURSOR cr_crapcol IS
   SELECT cop.cdcooper
   FROM crapcop cop
  WHERE cop.cdcooper <> 3;

  -- Cursor genérico de calendário
  rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

  vr_dtrefere crapdat.dtmvtolt%TYPE;
  vr_dtrefuti DATE;

  vr_tab_split_dias gene0002.typ_split;
  vr_idx_dia NUMBER;
  vr_email_enviado BOOLEAN := FALSE;

  CURSOR cr_dias_debito IS
    SELECT DISTINCT dsdias_debito dias
      FROM tbcrd_config_categoria con
          ,crapcop                cop
     WHERE con.cdcooper = cop.cdcooper
       AND cop.flgativo = 1
       AND con.cdcooper <> 3;

  --Cursor que retorna um resumo com aas somas dos lancamentos por fatura
  CURSOR cr_paga_fatura IS
      SELECT SUM(vlpagamento) vlpagamento
            ,pag.idfatura
            ,fat.nrdconta
            ,fat.nrconta_cartao
            ,ass.nrcpfcgc
        FROM tbcrd_pagamento_fatura pag
            ,tbcrd_fatura           fat
            ,crapass                ass
       WHERE pag.idfatura = fat.idfatura
         AND fat.dtref_pagodia = '03/07/2020'
         AND fat.vlpagodia > 0
         AND fat.inenvarq = 1
         AND pag.dtpagamento = '03/07/2020'
         AND pag.dtreferencia > TO_DATE('03/07/2020 08:00:00', 'DD/MM/YYYY HH24:MI:SS')
         AND pag.vlpagamento > 0
         AND fat.cdcooper = ass.cdcooper
         AND fat.nrdconta = ass.nrdconta
       GROUP BY pag.idfatura, fat.nrdconta ,fat.nrconta_cartao ,ass.nrcpfcgc;         
  rw_paga_fatura cr_paga_fatura%ROWTYPE;
     
  -- Informações arquivo bancoob
  CURSOR cr_crapscb IS 
    SELECT crapscb.dsdirarq
         , crapscb.nrseqarq
      FROM crapscb
     WHERE crapscb.tparquiv = 8; -- Arquivo DAUR
  rw_crapscb cr_crapscb%ROWTYPE;
      
BEGIN

  cecred.pc_log_programa(PR_DSTIPLOG   => 'I', 
                         PR_CDPROGRAMA => vr_nomdojob,
                         pr_tpexecucao => 2, -- job
                         PR_IDPRGLOG   => vr_idprglog);

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
  OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
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

  vr_dtrefere := TRUNC(to_date('03/07/2020', 'DD/MM/RRRR'));
     
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
                               TO_CHAR(vr_dtrefere,'YYYYMMDD') || '.' ||
                               TO_CHAR(SYSDATE,'HH24MISS') || '.CCB';     

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
  vr_dsheader := 'DAUR'                                   ||
                 '0'                                      ||
                 '756'                                    ||
                 TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0')) ||
                 TO_CHAR(vr_dtrefere,'DDMMYYYY')          ||                     
                 lpad(vr_nrseqarq,6,'0')                  || 
                 lpad(nvl(vr_contador,0),6,'0');
                     
  -- escrever HEADER do arquivo
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsheader);

  FOR rw_paga_fatura IN cr_paga_fatura LOOP                                             
    -- Contador de Registro
    vr_contador := vr_contador + 1;
        
    -- monta registro de DETALHE
    vr_dsdetarq := ('DAUR'                                          /* Retorno                       */         ||
                    '1'                                             /* Pgto Automático               */         ||
                    lpad(rw_paga_fatura.nrconta_cartao,13,'0')      /* Conta CABAL                   */         ||
                    lpad(nvl(rw_paga_fatura.nrcpfcgc,0),11,'0')     /* CPF                           */         ||
                    '0000000'                                       /* Filler                        */         ||
                    lpad(rw_paga_fatura.nrdconta,12,'0')            /* Conta/DV                      */         ||
                    '000000000'                                     /* Filler                        */         ||
                    '000000000000'                                  /* Filler                        */         ||
                    lpad(nvl((rw_paga_fatura.vlpagamento * 100),0),12,'0') /* Valor do Débito               */    ||
                    TO_CHAR(vr_dtrefere,'DDMMYYYY')                /* Data Venc. Fatura             */         ||
                    lpad(vr_contador,6,'0')                         /* Sequencial do Registro        */         );
                                                                        
    -- grava registro de DETALHE no arquivo
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsdetarq);
          
    -- Somatório do valor de Débitos Automáticos
    vr_vlrtotdb := vr_vlrtotdb + rw_paga_fatura.vlpagamento;
          
          
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

  COMMIT;

  cecred.pc_log_programa(PR_DSTIPLOG   => 'F', 
                         PR_CDPROGRAMA => vr_nomdojob,
                         PR_IDPRGLOG   => vr_idprglog);

EXCEPTION
  WHEN vr_exc_fimprg THEN

    cecred.pc_log_programa(PR_DSTIPLOG   => 'F', 
                           PR_CDPROGRAMA => vr_nomdojob,
                           PR_IDPRGLOG   => vr_idprglog);

    -- Buscar a descrição
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                  || vr_nomdojob || ' --> '
                                                                  || vr_dscritic );
    END IF;
        
    -- Efetuar commit
    COMMIT;

  WHEN vr_exc_saida THEN

    -- Devolvemos código e critica encontradas
    vr_cdcritic := NVL(vr_cdcritic,0);
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
    -- Efetuar rollback
    ROLLBACK;

    cecred.pc_log_programa(PR_DSTIPLOG   => 'E', 
                           PR_CDPROGRAMA => vr_nomdojob,
                           pr_cdcriticidade => 2,
                           pr_dsmensagem    => vr_dscritic,
                           pr_flgsucesso    => 0,
                           pr_tpocorrencia  => 1, -- erro de negócio
                           pr_tpexecucao    => 1, -- batch
                           PR_IDPRGLOG      => vr_idprglog);

    cecred.pc_log_programa(PR_DSTIPLOG   => 'F', 
                           PR_CDPROGRAMA => vr_nomdojob,
                           pr_flgsucesso => 0,
                           PR_IDPRGLOG   => vr_idprglog);
        
 WHEN OTHERS THEN

   cecred.pc_internal_exception(3);              

   -- Efetuar retorno do erro não tratado
   vr_cdcritic := 0;
   vr_dscritic := sqlerrm;
   -- Efetuar rollback
   ROLLBACK;

   cecred.pc_log_programa(PR_DSTIPLOG   => 'E', 
                          PR_CDPROGRAMA => vr_nomdojob,
                          pr_cdcriticidade => 2,
                          pr_dsmensagem    => vr_dscritic,
                          pr_flgsucesso    => 0,
                          pr_tpocorrencia  => 2, -- erro não tratado
                          pr_tpexecucao    => 1, -- batch
                          pr_flabrechamado => 1, -- Abrir chamado (Sim=1/Nao=0)
                          pr_texto_chamado => ' Verificar execução do job ' || vr_nomdojob || 
                                              ': Gerar arquivo de retorno de Débito em conta das faturas (Bancoob/CABAL). ',
                          pr_destinatario_email => gene0001.fn_param_sistema('CRED',3,'CRD_RESPONSAVEL'),
                          pr_flreincidente => 1, --> Erro pode ocorrer em dias diferentes, devendo abrir chamado
                          PR_IDPRGLOG      => vr_idprglog);

   cecred.pc_log_programa(PR_DSTIPLOG   => 'F', 
                          PR_CDPROGRAMA => vr_nomdojob,
                          pr_flgsucesso => 0,
                          PR_IDPRGLOG   => vr_idprglog);
END;
0
0
