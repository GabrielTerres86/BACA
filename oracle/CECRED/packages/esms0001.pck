CREATE OR REPLACE PACKAGE cecred.esms0001 AS
  
  PROCEDURE pc_cria_lote_sms(pr_cdproduto   IN tbgen_sms_lote.cdproduto%TYPE
                            ,pr_idtpreme    IN tbgen_sms_lote.idtpreme%TYPE
                            ,pr_dsagrupador IN tbgen_sms_lote.dsagrupador%TYPE DEFAULT NULL
                            ,pr_idlote_sms OUT tbgen_sms_lote.idlote_sms%TYPE
                            ,pr_dscritic   OUT VARCHAR2);
  
  PROCEDURE pc_escreve_sms(pr_idlote_sms  IN tbgen_sms_controle.idlote_sms%TYPE
                          ,pr_cdcooper    IN tbgen_sms_controle.cdcooper%TYPE
                          ,pr_nrdconta    IN tbgen_sms_controle.nrdconta%TYPE
                          ,pr_idseqttl    IN tbgen_sms_controle.idseqttl%TYPE
                          ,pr_dhenvio     IN tbgen_sms_controle.dhenvio_sms%TYPE
                          ,pr_nrddd       IN tbgen_sms_controle.nrddd%TYPE
                          ,pr_nrtelefone  IN tbgen_sms_controle.nrtelefone%TYPE
                          ,pr_cdtarifa    IN tbgen_sms_controle.cdtarifa%TYPE DEFAULT NULL
                          ,pr_dsmensagem  IN tbgen_sms_controle.dsmensagem%TYPE
                          
                          ,pr_idsms      OUT tbgen_sms_controle.idsms%TYPE
                          ,pr_dscritic   OUT VARCHAR2);
  
  PROCEDURE pc_conclui_lote_sms(pr_idlote_sms IN OUT tbgen_sms_controle.idlote_sms%TYPE
                               ,pr_dscritic OUT VARCHAR2);
  
  PROCEDURE pc_dispacha_lotes_sms(pr_dscritic OUT VARCHAR2);
  
  PROCEDURE pc_retorna_lotes_sms(pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_escreve_sms_debaut(pr_cdcooper   IN tbgen_sms_controle.cdcooper%TYPE
                                 ,pr_nrdconta   IN tbgen_sms_controle.nrdconta%TYPE
                                 ,pr_dsmensagem IN tbgen_sms_controle.dsmensagem%TYPE
                                 ,pr_vlfatura   IN craplau.vllanaut%TYPE
                                 ,pr_idmotivo   IN tbgen_motivo.idmotivo%TYPE
                                 ,pr_cdrefere   IN crapatr.cdrefere%TYPE
                                 ,pr_cdhistor   IN crapatr.cdhistor%TYPE
                                 ,pr_idlote_sms IN OUT tbgen_sms_controle.idlote_sms%TYPE
                                 ,pr_dscritic   OUT VARCHAR2);

END esms0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.esms0001 AS

  idoperac_envio CONSTANT VARCHAR2(1) := 'E';
  idoperac_retorno CONSTANT VARCHAR2(1) := 'R';

  /*---------------------------------------------------------------------------------------------------------------
   Programa: ESMS0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
  
   Autor   : Dionathan
   Data    : 14/04/2016                        Ultima atualizacao:
   
   Objetivo  : Envio de SMS (Package Gen�rica)
  
   Alteracoes:    
  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_cria_lote_sms(pr_cdproduto     IN tbgen_sms_lote.cdproduto%TYPE
                            ,pr_idtpreme      IN tbgen_sms_lote.idtpreme%TYPE
                            ,pr_dsagrupador   IN tbgen_sms_lote.dsagrupador%TYPE DEFAULT NULL
                            ,pr_idlote_sms   OUT tbgen_sms_lote.idlote_sms%TYPE
                            ,pr_dscritic     OUT VARCHAR2) IS
    /*.............................................................................
    
        Programa: pc_cria_lote_sms
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Dionathan
        Data    : 02/05/2016                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Criar um novo registro de lote de SMS para envio
    
        Alteracoes:
    ..............................................................................*/
      
  BEGIN
    
    -- Insere um registro novo e retorna o id do lote
    INSERT INTO tbgen_sms_lote x
               (cdproduto
               ,idtpreme
               ,idsituacao
               ,dsagrupador)
        VALUES (pr_cdproduto
               ,pr_idtpreme
               ,'A' -- Aberto
               ,pr_dsagrupador)
     RETURNING idlote_sms
          INTO pr_idlote_sms;
  
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao criar lote de SMS: ' || SQLERRM;
  END pc_cria_lote_sms;
  
  PROCEDURE pc_escreve_sms(pr_idlote_sms  IN tbgen_sms_controle.idlote_sms%TYPE
                          ,pr_cdcooper    IN tbgen_sms_controle.cdcooper%TYPE
                          ,pr_nrdconta    IN tbgen_sms_controle.nrdconta%TYPE
                          ,pr_idseqttl    IN tbgen_sms_controle.idseqttl%TYPE
                          ,pr_dhenvio     IN tbgen_sms_controle.dhenvio_sms%TYPE
                          ,pr_nrddd       IN tbgen_sms_controle.nrddd%TYPE
                          ,pr_nrtelefone  IN tbgen_sms_controle.nrtelefone%TYPE
                          ,pr_cdtarifa    IN tbgen_sms_controle.cdtarifa%TYPE DEFAULT NULL
                          ,pr_dsmensagem  IN tbgen_sms_controle.dsmensagem%TYPE
                          
                          ,pr_idsms      OUT tbgen_sms_controle.idsms%TYPE
                          ,pr_dscritic   OUT VARCHAR2) IS
  
  BEGIN
    
    INSERT INTO tbgen_sms_controle
               (idlote_sms
               ,idsms
               ,cdcooper
               ,nrdconta
               ,idseqttl
               ,dhenvio_sms
               ,nrddd
               ,nrtelefone
               ,cdtarifa
               ,dsmensagem)
             VALUES
               (pr_idlote_sms
               ,(SELECT NVL(MAX(sms.idsms), 0) + 1
                  FROM tbgen_sms_controle sms
                 WHERE sms.idlote_sms = pr_idlote_sms)
               ,pr_cdcooper
               ,pr_nrdconta
               ,pr_idseqttl
               ,pr_dhenvio
               ,pr_nrddd
               ,pr_nrtelefone
               ,pr_cdtarifa
               ,pr_dsmensagem)
      RETURNING idsms
           INTO pr_idsms;
               
    
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao inserir SMS no lote '|| pr_idlote_sms ||': ' || SQLERRM;
  END;
  
  PROCEDURE pc_conclui_lote_sms(pr_idlote_sms IN OUT tbgen_sms_controle.idlote_sms%TYPE
                               ,pr_dscritic OUT VARCHAR2) IS
    /*.............................................................................
    
        Programa: pc_dispacha_lote_sms
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Dionathan
        Data    : 14/04/2016                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para gerar o arquivo de remessa SMS -> ZENVIA
    
        Alteracoes:
    ..............................................................................*/
    
  BEGIN
    
    UPDATE tbgen_sms_lote lot
       SET lot.idsituacao = 'P' -- Processado
     WHERE lot.idlote_sms = pr_idlote_sms;
     
    pr_idlote_sms := NULL;
    
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao concluir lote de SMS: ' || SQLERRM;
  END pc_conclui_lote_sms;
  
  PROCEDURE pc_insere_evento_remessa_sms(pr_idtpreme IN VARCHAR2            --> Tipo da remessa
                                        ,pr_dtmvtolt IN DATE                --> Data da remessa
                                        ,pr_cdesteve IN PLS_INTEGER         --> Est�gio do evento
                                        ,pr_flerreve IN PLS_INTEGER         --> Flag de evento de erro
                                        ,pr_dslogeve IN VARCHAR2            --> Log do evento
                                        ,pr_dscritic OUT VARCHAR2) IS       --> Retorno de cr�tica
  
  CURSOR cr_crapcrb IS
  SELECT crb.idtpreme
        ,crb.dtmvtolt
    FROM crapcrb crb
   WHERE crb.idtpreme = pr_idtpreme
     AND crb.dtmvtolt = TRUNC(pr_dtmvtolt);
  rw_crapcrb cr_crapcrb%ROWTYPE;
  cr_crapcrb_found BOOLEAN;
  
  BEGIN
  
  OPEN cr_crapcrb;
  FETCH cr_crapcrb
  INTO rw_crapcrb;
  cr_crapcrb_found := cr_crapcrb%FOUND;
  CLOSE cr_crapcrb;
  
  -- Cria um registro na CRAPCRB apenas para gerar log
  IF NOT cr_crapcrb_found THEN
    -- Rotina para solicitar o processo de envio / retorno dos arquivos dos Bureaux
    cybe0002.pc_solicita_remessa(pr_dtmvtolt => TRUNC(pr_dtmvtolt)  --> Data da solicita��o - Insere apenas 1 registro por dia, por isSO o TRUNC
                                ,pr_idtpreme => pr_idtpreme  --> Tipo da remessa
                                ,pr_dscritic => pr_dscritic); --> Retorno de cr�tica
  END IF;
  
  -- Centraliza��o da grava��o dos Eventos da Remessa
  cybe0002.pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme   --> Tipo da remessa
                                   ,pr_dtmvtolt => TRUNC(pr_dtmvtolt) --> Data da remessa
                                   ,pr_nrseqarq => NULL          --> Sequencial do arquivo (Opcional)
                                   ,pr_cdesteve => pr_cdesteve   --> Est�gio do evento
                                   ,pr_flerreve => pr_flerreve   --> Flag de evento de erro
                                   ,pr_dslogeve => pr_dslogeve   --> Log do evento
                                   ,pr_dscritic => pr_dscritic); --> Retorno de cr�tica
  
  END pc_insere_evento_remessa_sms;
  
  FUNCTION fn_nome_arquivo(pr_dtmvtolt   IN tbgen_sms_lote.dtmvtolt%TYPE
                          ,pr_idlote_sms IN tbgen_sms_lote.idlote_sms%TYPE
                          ,pr_idtpreme   IN tbgen_sms_lote.idtpreme%TYPE
                          ,pr_idoperac   IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
  RETURN to_char(pr_dtmvtolt, 'RRRRMMDD_HH24MISS') || '_' ||
                 pr_idlote_sms || '_' ||
                 pr_idtpreme ||
                 CASE pr_idoperac
                   WHEN idoperac_retorno -- Se for retono adiciona "_ret" no fim do nome
                   THEN '_ret'
                   END;
  
  END fn_nome_arquivo;
  
  PROCEDURE pc_processa_arquivo_ftp(pr_nmarquiv IN VARCHAR2              --> Nome arquivo a enviar/ String de busca do arquivo a receber
                                   ,pr_idoperac IN VARCHAR2              --> E - Envio de Arquivo, R - Retorno de arquivo
                                   ,pr_nmdireto IN VARCHAR2              --> Diret�rio do arquivo a enviar
                                   ,pr_idenvseg IN crapcrb.idtpreme%TYPE --> Indicador de utilizacao de protocolo seguro (SFTP)
                                   ,pr_ftp_site IN VARCHAR2              --> Site de acesso ao FTP
                                   ,pr_ftp_user IN VARCHAR2              --> Usu�rio para acesso ao FTP
                                   ,pr_ftp_pass IN VARCHAR2              --> Senha para acesso ao FTP
                                   ,pr_ftp_path IN VARCHAR2              --> Pasta no FTP para envio do arquivo
                                   ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de cr�tica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_envia_arquivo_ftp
    --  Sistema  : AYLLOS
    --  Sigla    : CRED
    --  Autor    : Dionathan Henchel
    --  Data     : Junho/2016                   Ultima atualizacao:
    --
    -- Dados referentes ao programa: 
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar envio do arquivo repassado para o FTP enviado como par�metro
    --
    -- Alteracoes: 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      vr_arquivo_log VARCHAR2(1000); --> Diret�rio do log do FTP
      vr_script_ftp VARCHAR2(1000); --> Script FTP
      vr_comand_ftp VARCHAR2(4000); --> Comando montado do envio ao FTP
      vr_typ_saida  VARCHAR2(3);    --> Sa�da de erro
    BEGIN
      --Chama script espec�fico para conex�o de ftp segura
      IF pr_idenvseg = 'S' THEN
        vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_SFTP');
      ELSE
        -- Buscar script para conex�o FTP
        vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_FTP');
      END IF;
      
      -- Gera o diret�rio do arquivo de log
      vr_arquivo_log := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                               ,pr_cdcooper => 3
                                               ,pr_nmsubdir => '/log') || '/proc_autbur.log'; 

      -- Preparar o comando de conex�o e envio ao FTP
      vr_comand_ftp := vr_script_ftp
                    || CASE pr_idoperac WHEN 'E' THEN ' -envia' ELSE ' -recebe' END
                    || ' -srv '          || pr_ftp_site
                    || ' -usr '          || pr_ftp_user
                    || ' -pass '         || pr_ftp_pass
                    || ' -arq '          || CHR(39) || pr_nmarquiv || CHR(39)
                    || ' -dir_local '    || CHR(39) || pr_nmdireto || CHR(39)
                    || ' -dir_remoto '   || CHR(39) || pr_ftp_path || CHR(39)
                    || ' -log ' || vr_arquivo_log;

      -- Chama procedure de envio e recebimento via ftp
      GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_ftp
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => pr_dscritic);

      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        RETURN;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro nao tratado na ESMS0001.pc_processa_arquivo_ftp: '||SQLERRM;
    END;
  END pc_processa_arquivo_ftp;
  
  PROCEDURE pc_dispacha_lotes_sms(pr_dscritic OUT VARCHAR2) IS
    /*.............................................................................
    
        Programa: pc_dispacha_lotes_sms
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Dionathan
        Data    : 14/04/2016                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para gerar o arquivo de remessa SMS e enviar para a ZENVIA
    
        Alteracoes:
    ..............................................................................*/
    
    -- Vari�vel de cr�ticas
    vr_dscritic VARCHAR2(10000);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis da procedure
    vr_dhenvio   DATE;
    vr_linha VARCHAR2(1000);
    
    -- Declarando handle do Arquivo
    vr_nmarquiv    VARCHAR2(100);
    vr_arquivo_rem utl_file.file_type;
    vr_arquivo_cfg utl_file.file_type;
      
    -- Busca os lotes de SMS
    CURSOR cr_lote IS
    SELECT lot.*
          ,pbc.idenvseg
          ,pbc.dssitftp
          ,pbc.dsusrftp
          ,pbc.dspwdftp
          ,pbc.dsdreftp
          ,pbc.dsdirenv
          ,pbc.dsdirret
      FROM tbgen_sms_lote lot
          ,crappbc        pbc
     WHERE lot.idtpreme = pbc.idtpreme
       AND lot.idsituacao = 'P';
    rw_lote cr_lote%ROWTYPE;
    
    -- Busca as mensagens pertencentes ao Lote
    CURSOR cr_sms(pr_idlote_sms IN tbgen_sms_controle.idlote_sms%TYPE) IS
    SELECT sms.*
          ,cop.nmrescop
      FROM tbgen_sms_controle sms
          ,crapcop            cop
     WHERE sms.cdcooper = cop.cdcooper
       AND sms.idlote_sms = pr_idlote_sms;
    
  BEGIN
    
    FOR rw_lote IN cr_lote LOOP
      
      -- Gera o nome do arquivo
      vr_dhenvio := SYSDATE;
      vr_nmarquiv := fn_nome_arquivo(pr_dtmvtolt   => vr_dhenvio
                                    ,pr_idlote_sms => rw_lote.idlote_sms
                                    ,pr_idtpreme   => rw_lote.idtpreme
                                    ,pr_idoperac   => idoperac_envio); -- Arquivo de envio
      
      -- criar arquivo .cfg
      -- Abre arquivo em modo de escrita (W)
      gene0001.pc_abre_arquivo(pr_nmdireto => rw_lote.dsdirenv --> Diret�rio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv || '.cfg' --> Nome do arquivo
                              ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_arquivo_cfg --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic); --> Erro
      
      -- gravar linha no arquivo
      gene0001.pc_escr_linha_arquivo(vr_arquivo_cfg
                                    ,'1;' || vr_nmarquiv || '.txt' || CHR(13) || CHR(10) ||
                                     '2;' || 'D' || CHR(13) || CHR(10) ||
                                     '3;' || to_char(vr_dhenvio, 'DD/MM/RRRR;HH24:MI:SS') || CHR(13) || CHR(10) ||
                                     '5;' || rw_lote.dsagrupador || CHR(13) || CHR(10) ||
                                     '6;' || to_char(vr_dhenvio + (60 / 60 / 24), 'DD/MM/RRRR;HH24:MI:SS') || CHR(13) || CHR(10) ||
                                     '7;' || vr_nmarquiv || '_ret.txt' || CHR(13) || CHR(10));
      
      -- criar arquivo .txt
      -- Abre arquivo em modo de escrita (W)
      gene0001.pc_abre_arquivo(pr_nmdireto => rw_lote.dsdirenv --> Diret�rio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv || '.txt' --> Nome do arquivo
                              ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_arquivo_rem --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic); --> Erro
      
      -- Loop que percorre os SMS do lote
      FOR rw_sms IN cr_sms(pr_idlote_sms => rw_lote.idlote_sms) LOOP
        
        -- Construir a linha do arquivo - LAYOUT E -> ZENVIA
        -- LAYOUT E -> celular;msg;id;remetente;dataEnvio
        vr_linha := '55' || rw_sms.nrddd || rw_sms.nrtelefone || ';' || -- Celular
                    TRIM(RPAD(REPLACE(rw_sms.dsmensagem,';','.'), 160-LENGTH(rw_sms.nmrescop),' ')) || ';' || -- mensagem de texto (deve possuir no maximo 160 caracteres considerando o remetente)
                    rw_sms.idsms || ';' || -- Id interno (Lote/SMS)
                    rw_sms.nmrescop || ';' || -- Remetente
                    to_char(rw_sms.dhenvio_sms, 'dd/mm/yyyy hh24:mm:ss') || CHR(13); -- Data do envio
        
        -- Gravar linha no arquivo                    
        GENE0001.pc_escr_linha_arquivo(vr_arquivo_rem,vr_linha);
      
      END LOOP; -- Fim do loop que percorre os SMS do lote
      
      -- Fechar os arquivos
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_cfg);
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_rem);
      
      -- Envia os dois arquivos via FTP (.txt e .cfg)
      FOR i IN 1..2 LOOP
        -- Envio via FTP
        pc_processa_arquivo_ftp(pr_nmarquiv => vr_nmarquiv || CASE i WHEN 1 THEN '.txt' ELSE '.cfg' END --> Nome arquivo a enviar
                               ,pr_idoperac => 'E'                --> Envio de arquivo
                               ,pr_nmdireto => rw_lote.dsdirenv   --> Diret�rio do arquivo a enviar
                               ,pr_idenvseg => rw_lote.idenvseg   --> Indicador de utilizacao de protocolo seguro (SFTP)
                               ,pr_ftp_site => rw_lote.dssitftp   --> Site de acesso ao FTP
                               ,pr_ftp_user => rw_lote.dsusrftp   --> Usu�rio para acesso ao FTP
                               ,pr_ftp_pass => rw_lote.dspwdftp   --> Senha para acesso ao FTP
                               ,pr_ftp_path => rw_lote.dsdreftp   --> Pasta no FTP para envio do arquivo
                               ,pr_dscritic => vr_dscritic);      --> Retorno de cr�tica
        
        IF vr_dscritic IS NOT NULL THEN
          EXIT;
        END IF;
      END LOOP;
      
      -- Se enviou com sucesso
      IF vr_dscritic IS NULL THEN
        
        UPDATE tbgen_sms_lote lot
           SET lot.idsituacao = 'E' -- Em espera de Retorno
              ,lot.dtmvtolt = vr_dhenvio
         WHERE lot.idlote_sms = rw_lote.idlote_sms;
         
        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => vr_dhenvio --> Data passada
                                             ,pr_cdesteve => 1                --> Agendamento
                                             ,pr_flerreve => 0                --> N�o houve erro
                                             ,pr_dslogeve => 'Arquivo de remessa '||vr_nmarquiv||'.txt  enviada com sucesso em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss')
                                             ,pr_dscritic => pr_dscritic); --> Retorno de cr�tica
         
      ELSE -- Se ocorreu erro cancela o lote
      
        UPDATE tbgen_sms_lote lot
           SET lot.idsituacao = 'C' --Cancelado
         WHERE lot.idlote_sms = rw_lote.idlote_sms;
         
        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => vr_dhenvio       --> Data passada
                                             ,pr_cdesteve => 9                --> Cancelado
                                             ,pr_flerreve => 1                --> Erro
                                             ,pr_dslogeve => 'Remessa '||rw_lote.idtpreme||' cancelada por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss')
                                             ,pr_dscritic => pr_dscritic); --> Retorno de cr�tica
        
      END IF;
      
    END LOOP;
     
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao dispachar lotes de SMS: ' || SQLERRM;
  END pc_dispacha_lotes_sms;
  
  PROCEDURE pc_retorna_lotes_sms(pr_dscritic OUT VARCHAR2) IS
    /*.............................................................................
    
        Programa: pc_retorna_lotes_sms
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Dionathan
        Data    : 14/04/2016                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar os arquivos de retorno de SMS no ftp da ZENVIA
    
        Alteracoes:
        
              26/10/2016 - Incluso verifica��o de existencia do arquivo, antes da abertura
                           do mesmo. Estavam ocorrendo erros no log de produ��o por tentar
                           abrir arquivos ainda n�o recebidos. (Renato Darosci - Supero)
                           
    ..............................................................................*/
    
    -- Vari�vel de cr�ticas
    vr_dscritic VARCHAR2(10000);
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis da procedure
    vr_linha VARCHAR2(1000);
    
    -- Declarando handle do Arquivo
    vr_nmarquiv    VARCHAR2(200);
    vr_arquivo_ret utl_file.file_type;
    vr_nmarqenc VARCHAR2(4000);        --> Lista de arquivos encontrados
    
    -- Tabela de String
    vr_tab_string        gene0002.typ_split;
      
    -- Busca os lotes de SMS
    CURSOR cr_lote IS
    SELECT lot.*
          ,pbc.idenvseg
          ,pbc.dssitftp
          ,pbc.dsusrftp
          ,pbc.dspwdftp
          ,pbc.dsdrrftp
          ,pbc.dsdirret
      FROM tbgen_sms_lote lot
          ,crappbc        pbc
     WHERE lot.idtpreme = pbc.idtpreme
       AND lot.idsituacao = 'E' --Em espera de Retorno
       AND (SYSDATE-lot.dtmvtolt) <= 2; -- No m�ximo at� 2 dias atr�s
    rw_lote cr_lote%ROWTYPE;
    
  BEGIN
    
    FOR rw_lote IN cr_lote LOOP
      
      vr_nmarquiv := fn_nome_arquivo(pr_dtmvtolt   => rw_lote.dtmvtolt
                                    ,pr_idlote_sms => rw_lote.idlote_sms
                                    ,pr_idtpreme   => rw_lote.idtpreme
                                    ,pr_idoperac   => idoperac_retorno) || '.txt'; -- Arquivo de retorno
      
      pc_processa_arquivo_ftp(pr_nmarquiv => vr_nmarquiv      --> Nome arquivo a receber
                             ,pr_idoperac => idoperac_retorno --> Envio de arquivo
                             ,pr_nmdireto => rw_lote.dsdirret||'/temp' --> Diret�rio do arquivos de retorno
                             ,pr_idenvseg => rw_lote.idenvseg --> Indicador de utilizacao de protocolo seguro (SFTP)
                             ,pr_ftp_site => rw_lote.dssitftp --> Site de acesso ao FTP
                             ,pr_ftp_user => rw_lote.dsusrftp --> Usu�rio para acesso ao FTP
                             ,pr_ftp_pass => rw_lote.dspwdftp --> Senha para acesso ao FTP
                             ,pr_ftp_path => rw_lote.dsdrrftp --> Pasta no FTP para retorno do arquivo
                             ,pr_dscritic => vr_dscritic);    --> Retorno de cr�tica
      
      -- Se ocorreu erro ao receber o arquivo pula para o proximo lote
      IF vr_dscritic IS NOT NULL THEN
         
        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                             ,pr_cdesteve => 9                --> Cancelado
                                             ,pr_flerreve => 1                --> Erro
                                             ,pr_dslogeve => 'Retorno do lote '||vr_nmarquiv||' cancelado por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss') ||': '||vr_dscritic
                                             ,pr_dscritic => pr_dscritic); --> Retorno de cr�tica
        vr_dscritic := NULL;
        CONTINUE;
      END IF;
      
      -- Agora, listamos o arquivo baixado no diret�rio
      gene0001.pc_lista_arquivos(pr_path     => rw_lote.dsdirret||'/temp' --> Dir busca
                                ,pr_pesq     => vr_nmarquiv   --> Nome do arquivo (Chave de busca)
                                ,pr_listarq  => vr_nmarqenc   --> Arquivo encontrado (S� deve encontrar 1 arquivo, pois a chave de busca j� � o nome completo)
                                ,pr_des_erro => pr_dscritic); --> Poss�vel erro
      
      -- Se ocorreu erro pula para o proximo lote
      IF pr_dscritic IS NOT NULL THEN
         
        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                             ,pr_cdesteve => 9                --> Cancelado
                                             ,pr_flerreve => 1                --> Erro
                                             ,pr_dslogeve => 'Retorno do lote '||vr_nmarquiv||' cancelado por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss') ||': '||vr_dscritic
                                             ,pr_dscritic => pr_dscritic); --> Retorno de cr�tica
        vr_dscritic := NULL;
        CONTINUE;
      END IF;
      
      -- Deve verificar se o arquivo foi encontrado antes de tentar abrir o mesmo
      -- O arquivo n�o ser encontrado n�o caracteriza erro necessariamente, pois pode
      -- ser apenas que ele ainda n�o tenha sido disponibilizado devido ao hor�rio
      IF vr_nmarqenc IS NULL THEN
        -- Neste caso, deve pular para o pr�ximo
        CONTINUE;
      END IF;
      
      -- Abrir Arquivo
      gene0001.pc_abre_arquivo(pr_nmdireto => rw_lote.dsdirret||'/temp' --> Diretorio do arquivo
                              ,pr_nmarquiv => vr_nmarquiv      --> Nome do arquivo
                              ,pr_tipabert => 'R'              --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_arquivo_ret   --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);    --> Erro
      
      -- Se ocorreu erro pula para o proximo lote
      IF vr_dscritic IS NOT NULL THEN
         
        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                             ,pr_cdesteve => 9                --> Cancelado
                                             ,pr_flerreve => 1                --> Erro
                                             ,pr_dslogeve => 'Retorno do lote '||vr_nmarquiv||' cancelado por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss') ||': '||vr_dscritic
                                             ,pr_dscritic => pr_dscritic); --> Retorno de cr�tica
        vr_dscritic := NULL;
        CONTINUE;
      END IF;

      -- Se o arquivo estiver aberto
      IF  utl_file.IS_OPEN(vr_arquivo_ret) THEN
        
        -- Percorrer as linhas do arquivo
        BEGIN
          LOOP
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arquivo_ret
                                        ,pr_des_text => vr_linha);                                        
            
            -- Quebrar Informacoes da String e colocar no vetor
            vr_linha := REPLACE(vr_linha,chr(13),'');          
            vr_tab_string := gene0002.fn_quebra_string(vr_linha,';');
                  
            -- vr_tab_string(3) ISSO AQUI PEGA O IDENTIFICADOR DO SMS
                  
            -- 1 - Agendado
            -- 2 - Enviado
            -- 3 - Entregue
            -- 4 - Nao recebido
            -- 5 - Fora do plano de numeracao
            -- 6 - Blacklist
            -- 7 - Limpeza preditiva
            -- 8 - Erro
            -- 9 - Cancelado
                 
            UPDATE tbgen_sms_controle sms
               SET sms.cdretorno = to_number(vr_tab_string(6)) -- C�digo do retorno
             WHERE sms.idlote_sms = rw_lote.idlote_sms
               AND sms.idsms = to_number(vr_tab_string(3));
                
          END LOOP; -- loop do arquivo
            
        EXCEPTION
          WHEN no_data_found THEN
            -- Acabou a leitura
            NULL;
          WHEN OTHERS THEN
            esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                                 ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                                 ,pr_cdesteve => 9                --> Cancelado
                                                 ,pr_flerreve => 1                --> Erro
                                                 ,pr_dslogeve => 'Retorno do lote '||vr_nmarquiv||' cancelado por movito de erro em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss') ||': '||vr_dscritic
                                                 ,pr_dscritic => pr_dscritic); --> Retorno de cr�tica
            vr_dscritic := NULL;
            CONTINUE;
        END;
            
        UPDATE tbgen_sms_lote lot
           SET lot.idsituacao = 'R'
              ,lot.dhretorno = SYSDATE
         WHERE lot.idlote_sms = rw_lote.idlote_sms;
        
        esms0001.pc_insere_evento_remessa_sms(pr_idtpreme => rw_lote.idtpreme --> Bureaux passado
                                             ,pr_dtmvtolt => rw_lote.dtmvtolt --> Data passada
                                             ,pr_cdesteve => 1                --> Agendamento
                                             ,pr_flerreve => 0                --> N�o houve erro
                                             ,pr_dslogeve => 'Arquivo de retorno '||vr_nmarquiv||' recebido com sucesso em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss')
                                             ,pr_dscritic => pr_dscritic); --> Retorno de cr�tica
      END IF; -- IF arquivo aberto          
            
      -- Se o arquivo estiver aberto
      IF  utl_file.IS_OPEN(vr_arquivo_ret) THEN
        -- Fechar os arquivos
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo_ret);
      END IF;
      
      -- Tira o arquivo retorno da pasta temp
      gene0001.pc_OScommand_Shell('mv ' || rw_lote.dsdirret || '/temp' || '/' || vr_nmarqenc || ' ' ||
                                           rw_lote.dsdirret || '/' || vr_nmarqenc);
      
    END LOOP;
     
  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao processar retorno dos lotes de SMS: ' || SQLERRM;
  END pc_retorna_lotes_sms;
  
  PROCEDURE pc_escreve_sms_debaut(pr_cdcooper   IN tbgen_sms_controle.cdcooper%TYPE
                                 ,pr_nrdconta   IN tbgen_sms_controle.nrdconta%TYPE
                                 ,pr_dsmensagem IN tbgen_sms_controle.dsmensagem%TYPE
                                 ,pr_vlfatura   IN craplau.vllanaut%TYPE
                                 ,pr_idmotivo   IN tbgen_motivo.idmotivo%TYPE
                                 ,pr_cdrefere   IN crapatr.cdrefere%TYPE
                                 ,pr_cdhistor   IN crapatr.cdhistor%TYPE
                                 ,pr_idlote_sms IN OUT tbgen_sms_controle.idlote_sms%TYPE
                                 ,pr_dscritic   OUT VARCHAR2) IS
  /* .............................................................................

      Programa: pc_processa_retorno_sms
      Sistema : CECRED
      Autor   : Dionathan Henchel
      Data    : Maio/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para criar registro de sms para d�bito autom�tico

      Observacao: -----

      Alteracoes: 
 	 ..............................................................................*/																								
    
    vr_idsms tbgen_sms_controle.idsms%TYPE;
    
    vr_cdhistar INTEGER;  --Codigo Historico
    vr_cdhisest NUMBER;   --Historico Estorno
    vr_vltarifa NUMBER;   --Valor tarifa
    vr_dtdivulg DATE;     --Data Divulgacao
    vr_dtvigenc DATE;     --Data Vigencia
    vr_cdfvlcop INTEGER;  --Codigo faixa valor cooperativa
    vr_cdcritic INTEGER;  --Codigo Critica
    vr_dscritic VARCHAR2(4000);  --Descricao Critica
    vr_tab_erro GENE0001.typ_tab_erro; --Tabela erros
   
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
      
    CURSOR cr_debaut IS
      SELECT tfc.cdcooper
            ,tfc.nrdconta
            ,tfc.idseqttl
            ,TRUNC(SYSDATE) + (prm.hrenvio_sms / 60 / 60 / 24) dhenvio
            ,tfc.nrdddtfc
            ,tfc.nrtelefo
            ,CASE
               WHEN prm.flgcobra_tarifa = 1 THEN
                DECODE(ass.inpessoa, 1, prm.cdtarifa_pf, prm.cdtarifa_pj)
             END cdtarifa
            ,prm.flgenvia_sms
            ,prm.flgcobra_tarifa
            ,cop.nmrescop
        FROM crapcop         cop
            ,crapass         ass
            ,craptfc         tfc
            ,tbgen_sms_param prm
       WHERE ass.cdcooper = cop.cdcooper
         AND ass.cdcooper = tfc.cdcooper
         AND ass.nrdconta = tfc.nrdconta
         AND prm.cdcooper = tfc.cdcooper
         AND tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.flgacsms = 1;
    rw_debaut cr_debaut%ROWTYPE;
    
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    
    --Rowid lancamento tarifa
    vr_rowid_craplat ROWID;
  
  BEGIN
  
    OPEN cr_debaut;
    FETCH cr_debaut
      INTO rw_debaut;
    CLOSE cr_debaut;
    
    -- Se cooperativa n�o envia sms retorna sem gravar registro de sms
    IF rw_debaut.flgenvia_sms <> 1 THEN
      RETURN;
    END IF;
  
    -- Se telefone estiver vazio retorna sem gravar registro de sms
    IF rw_debaut.nrtelefo IS NULL THEN
      RETURN;
    END IF;
    
    -- Se ainda n�o criou lote
    IF pr_idlote_sms IS NULL THEN
    
      esms0001.pc_cria_lote_sms(pr_cdproduto     => 10 -- D�bito Autom�tico 
                               ,pr_idtpreme      => 'SMSDEBAUT'
                               ,pr_idlote_sms    => pr_idlote_sms
                               ,pr_dsagrupador   => rw_debaut.nmrescop
                               ,pr_dscritic      => pr_dscritic);
    
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
    END IF;
  
    esms0001.pc_escreve_sms(pr_idlote_sms => pr_idlote_sms
                           ,pr_cdcooper   => rw_debaut.cdcooper
                           ,pr_nrdconta   => rw_debaut.nrdconta
                           ,pr_idseqttl   => rw_debaut.idseqttl
                           ,pr_dhenvio    => rw_debaut.dhenvio
                           ,pr_nrddd      => rw_debaut.nrdddtfc
                           ,pr_nrtelefone => rw_debaut.nrtelefo
                           ,pr_cdtarifa   => rw_debaut.cdtarifa
                           ,pr_dsmensagem => pr_dsmensagem
                           
                           ,pr_idsms      => vr_idsms
                           ,pr_dscritic   => pr_dscritic);
                           
    IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;
    
    IF rw_debaut.flgcobra_tarifa = 1 THEN
      -- Busca valor da tarifa
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => rw_debaut.cdcooper  --Codigo Cooperativa
                                            ,pr_cdtarifa  => rw_debaut.cdtarifa  --Codigo Tarifa
                                            ,pr_vllanmto  => 0            --Valor Lancamento
                                            ,pr_cdprogra  => NULL         --Codigo Programa
                                            ,pr_cdhistor  => vr_cdhistar  --Codigo Historico da tarifa
                                            ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                            ,pr_vltarifa  => vr_vltarifa  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                            ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                            ,pr_tab_erro  => vr_tab_erro); --Tabela erros
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          pr_dscritic:= vr_tab_erro(1).dscritic;
        ELSE
          pr_dscritic:= 'Nao foi possivel carregar a tarifa.';
        END IF;
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      
      -- Validar data cooper
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
         CLOSE btch0001.cr_crapdat;

        vr_cdcritic := 0;
        vr_dscritic := 'Sistema sem data de movimento.';
        RAISE vr_exc_saida;
      ELSE
         CLOSE btch0001.cr_crapdat;
      END IF;
      
      --Inicializar variavel retorno erro
      TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => rw_debaut.cdcooper  --Codigo Cooperativa
                                       ,pr_nrdconta => rw_debaut.nrdconta  --Numero da Conta
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Lancamento
                                       ,pr_cdhistor => vr_cdhistar         --Codigo Historico
                                       ,pr_vllanaut => vr_vltarifa         --Valor lancamento automatico
                                       ,pr_cdoperad => 1   		             --Codigo Operador
                                       ,pr_cdagenci => 1                   --Codigo Agencia
                                       ,pr_cdbccxlt => 100                 --Codigo banco caixa
                                       ,pr_nrdolote => 33000               --Numero do lote
                                       ,pr_tpdolote => 1                   --Tipo do lote
                                       ,pr_nrdocmto => 0                   --Numero do documento
                                       ,pr_nrdctabb => pr_nrdconta         --Numero da conta
                                       ,pr_nrdctitg => to_char(pr_nrdconta,'fm00000000') --Conta Integracao   --Numero da conta integracao
                                       ,pr_cdpesqbb => ''                  --Codigo pesquisa
                                       ,pr_cdbanchq => 0                   --Codigo Banco Cheque
                                       ,pr_cdagechq => 0                   --Codigo Agencia Cheque
                                       ,pr_nrctachq => 0                   --Numero Conta Cheque
                                       ,pr_flgaviso => FALSE               --Flag aviso
                                       ,pr_tpdaviso => 0                   --Tipo aviso
                                       ,pr_cdfvlcop => vr_cdfvlcop         --Codigo cooperativa
                                       ,pr_inproces => rw_crapdat.inproces --Indicador processo
                                       ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                       ,pr_tab_erro => vr_tab_erro         --Tabela retorno erro
                                       ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                       ,pr_dscritic => vr_dscritic);       --Descricao Critica
      
    END IF;
    
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Se possui erro no vetor
      IF vr_tab_erro.Count > 0 THEN
        pr_dscritic:= vr_tab_erro(1).dscritic;
      ELSE
        pr_dscritic:= 'Nao foi possivel carregar a tarifa.';
      END IF;
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;
    
    -- Insere o Motivo da Mensagem (Utilizado no BI)
    BEGIN
      INSERT INTO tbconv_motivo_msg mtv
        (mtv.cdcooper
        ,mtv.nrdconta
        ,mtv.cdreferencia
        ,mtv.dhtentativa
        ,mtv.idmotivo
        ,mtv.vlfatura
        ,mtv.vltarifa
        ,mtv.idsms
        ,mtv.cdhistor
        ,mtv.idlote_sms)
      VALUES
        (rw_debaut.cdcooper
        ,rw_debaut.nrdconta
        ,pr_cdrefere
        ,SYSDATE
        ,pr_idmotivo
        ,pr_vlfatura
        ,vr_vltarifa
        ,vr_idsms
        ,pr_cdhistor
        ,pr_idlote_sms);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao inserir motivo da mensagem: '||SQLERRM;
        RAISE vr_exc_saida;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN    
      IF pr_dscritic IS NULL THEN
        pr_dscritic := 'Erro nao tratado na rotina ESMS0001.pc_escreve_sms_debaut: ' || SQLERRM;
      END IF;
  END;

END esms0001;
/
