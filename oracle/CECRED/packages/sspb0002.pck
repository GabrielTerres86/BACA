CREATE OR REPLACE PACKAGE CECRED.SSPB0002 AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: SSPB0002
--    Autor   : Douglas Quisinski
--    Data    : Julho/2015                      Ultima Atualizacao:   /  /    
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da conciliação de arquivos do SPB.
--
--    Alteracoes: 
--    
---------------------------------------------------------------------------------------------------------------

  /* Rotina para processar o arquivo de conciliação de TED/TEC */
  PROCEDURE pc_proc_concilia_ted_tec(pr_dspartes   IN VARCHAR2           --> Partes => PJA(JDSPB / AYLLOS)
                                    ,pr_dsdopcao   IN VARCHAR2           --> Opção => OT (Todos) / OI (Indícios de Duplicidade) 
                                    ,pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  /* Rotina para paginar as criticas da conciliação de TED/TEC */
  PROCEDURE pc_paginar_criticas(pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo
                               ,pr_nrinicri   IN INTEGER            --> Numero da critica Inicial
                               ,pr_nrqtdcri   IN INTEGER            --> Quantidade de Criticas para paginar
                               ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
                               

  /* Sprint D - Rotina para gerar o arquivo contabil */                               
  PROCEDURE pc_gera_arquivo_contabil (pr_cdcritic OUT crapcri.cdcritic%TYPE
                                              ,pr_dscritic OUT VARCHAR2);

  FUNCTION fn_depara_situacao_enviada (ds_sitaimaro IN VARCHAR2  --> Situação no Aimaro
                                      ,ds_sitjd     IN VARCHAR2) --> Situação na JD
                                      return boolean;
 
  FUNCTION fn_depara_situacao_recebida (ds_sitaimaro IN VARCHAR2  --> Situação no Aimaro
                                      ,ds_sitjd     IN VARCHAR2) --> Situação na JD
                                      return boolean;


  PROCEDURE pc_gera_conciliacao_spb (pr_tipo_concilacao IN VARCHAR2 --> Tipo de execução (D - Diaria, M - Manual)
                                   ,pr_tipo_mensagem    IN VARCHAR2 --> Tipo de mensagem a conciliar (E - Enviada, R - Recebida, T - Todas)
                                   ,pr_data_ini IN VARCHAR2             --> Data de início da conciliação
                                   ,pr_data_fim IN VARCHAR2           --> Data de fim da conciliação
                                   ,pr_dsendere IN VARCHAR2       --> Endereço de email a ser enviado a notificação
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2);    --> Descrição da crítica


END SSPB0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SSPB0002 AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: SSPB0002
--    Autor   : Douglas Quisinski
--    Data    : Julho/2015                      Ultima Atualizacao: 08/06/2017
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da conciliação de arquivos do SPB.
--
--    Alteracoes: 22/04/2016 - Ajustado o nome do diretorio de upload do arquivo e 
--                             a query de busca na gnmvspb (Douglas - Melhoria 085)
--    
--                08/08/2016 - Ajustado a busca do valor de conciliação da linha do arquivo
--                             para que seja tratado o valor com ou sem a separação de 
--                             milhares e decimais na procedure pc_proc_arq_jdspb_ayllos 
--                            (Douglas - Chamado 501071)
--
--                10/11/2016 - Ajustado a conciliação das mensagens de VR Boleto
--                             (Douglas - Chamado 503347)
--
--                12/12/2016 - Ajustar conciliação para que durante o periodo de 01/01/2017 até 21/03/2017
--                             (mesmo período em que o DE->PARA ira ocorrer no crps531_1 que processa as 
--                             mensagens de TED) (Douglas - Chamado 570148)
--
--                15/05/2017 - Adicionar conciliação das mensagens STR0010, PAG0111, STR0048
--                             (Douglas - Chamado 524133)
--
--                08/06/2017 - Adicionar mensagens 'PAG0142R2','STR0034R2','PAG0134R2' referentes ao
--                             novo catalogo do SPB (Lucas Ranghetti #668207)
--
--                08/01/2019 - Sprint D - Req19 - Rotina para gerar arquivo contabil (Jose Dill - Mouts)
--
--                10/05/2019 - Sprint D2/E1 - Req34/Req36 - Rotina para gerar a conciliação (Jose Dill - Mouts)
--
---------------------------------------------------------------------------------------------------------------
  -- Tipo de registro para conter as informações das linhas do arquivo
  TYPE typ_recdados IS RECORD (nrdlinha INTEGER
                              ,dsduplic VARCHAR(1) 
                              ,cddotipo VARCHAR2(20)
                              ,nrcontro VARCHAR2(20)
                              ,nrctrlif VARCHAR2(25)
                              ,vlconcil NUMBER(25,2)
                              ,dtmensag VARCHAR2(10)
                              ,dsdahora VARCHAR2(20)
                              ,dscritic VARCHAR2(1000)
                              ,dsorigem VARCHAR2(20)
                              ,dsespeci VARCHAR2(5)
                              ,cddbanco_deb INTEGER
                              ,cdagenci_deb INTEGER
                              ,nrdconta_deb NUMBER(20)
                              ,nrcpfcgc_deb VARCHAR2(20)
                              ,nmcooper_deb VARCHAR2(100)
                              ,cddbanco_cre INTEGER
                              ,cdagenci_cre INTEGER
                              ,nrdconta_cre NUMBER(20)
                              ,nrcpfcgc_cre VARCHAR2(20)
                              ,nmcooper_cre VARCHAR2(100)
                              ,dsorigemerro VARCHAR2(20));
                              
  -- tabela de criticas
  TYPE typ_tbcritica IS TABLE OF typ_recdados INDEX BY VARCHAR2(150);
  -- tabela de linhas arquivos
  TYPE typ_tbarquivo IS TABLE OF typ_recdados INDEX BY VARCHAR2(150);
  -- tabela de registros ayllos
  TYPE typ_tbayllos  IS TABLE OF typ_recdados INDEX BY VARCHAR2(150);
  -- tabela de linhas processadas
  TYPE typ_tbprocessados IS TABLE OF typ_recdados INDEX BY VARCHAR2(150);

  PROCEDURE pc_proc_arq_jdspb_ayllos(pr_cdcooper IN     PLS_INTEGER   --> Cooperativa
                                    ,pr_nmdireto IN     VARCHAR2      --> Diretorio do Arquivo
                                    ,pr_nmarquiv IN     VARCHAR2      --> Nome do Arquivo
                                    ,pr_dsdopcao IN     VARCHAR2      --> Opção => OT (Todos) / OI (Indícios de Duplicidade) 
                                    ,pr_tbcritic IN OUT typ_tbcritica --> Tabela de criticas encontradas na validação do arquivo
                                    ,pr_cdcritic    OUT PLS_INTEGER   --> Código da crítica
                                    ,pr_dscritic    OUT VARCHAR2) IS  --> Descrição da crítica
  BEGIN
    /* .............................................................................
    Programa: pc_proc_arq_jdspb_ayllos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 04/08/2015                        Ultima atualizacao: 08/06/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para processar o arquivo de conciliação entre JDSPB/AYLLOS

    Especificação dos campos do arquivo de conciliação entre JDSPB/AYLLOS (separados por ";"):
        - Grupo
        - Data Mensagem
        - Hora Mensagem
        - Hora Efetivação
        - Área Neg.
        - Mensagem
        - Nº Msg
        - Num. Ctrl IF
        - ISPB IF Creditada
        - IF Creditada
        - Cliente Creditado
        - CNPJ / CPF Creditado
        - Conta Creditada
        - Agencia Creditada
        - Tipo Conta Cred.
        - ISPB IF Debitada
        - IF Debitada
        - Cliente Debitado
        - CNPJ / CPF Debitado
        - Conta Debitada
        - Agencia Debitada
        - Tipo Conta Deb.
        - Valor
        - Cód. Ident. Transf
        - Finalidade Cliente
        - Situação Msg
        - Num. Ctrl PAG/STR
        - Devolução da Transferência
        - Nr. Op
          
    Alteracoes: 08/08/2016 - Ajustado a busca do valor de conciliação da linha do arquivo
                             para que seja tratado o valor com ou sem a separação de 
                             milhares e decimais (Douglas - Chamado 501071)
                             
                12/12/2016 - Ajustar conciliação para que durante o periodo de 
                             01/01/2017 até 21/03/2017 (mesmo período em que o DE->PARA 
                             ira ocorrer no crps531_1 que processa as  mensagens de TED) 
                             (Douglas - Chamado 570148)                             
                
                15/05/2017 - Adicionar conciliação das mensagens STR0010, PAG0111, STR0048
                             (Douglas - Chamado 524133)

                08/06/2017 - Adicionar mensagens 'PAG0142R2','STR0034R2','PAG0134R2' referentes ao
                             novo catalogo do SPB (Lucas Ranghetti #668207)
    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro  EXCEPTION;
      
      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variáveis para ler arquivo
      vr_dsdlinha VARCHAR2(32726);
      vr_utlfileh UTL_FILE.file_type;
      vr_des_erro crapcri.dscritic%TYPE;

      vr_arr_concil  gene0002.typ_split;
      
      -- Identificação da Transação
      vr_grupo    VARCHAR2(10);
      vr_dtmensag DATE;
      vr_hrmensag VARCHAR2(10);
      vr_hrefetiv VARCHAR2(10);
      vr_dsareneg VARCHAR2(10);
      vr_dsmensag VARCHAR2(20);
      vr_nrmensag INTEGER;
      vr_nrctrlif VARCHAR2(25);
      -- Conta Creditada
      vr_ispbif_cre   INTEGER;
      vr_nmif_cre     VARCHAR2(50);
      vr_nmcli_cre    VARCHAR2(200);
      vr_nrcpfcgc_cre VARCHAR2(20);
      vr_nrcpfcgc_cre_pesq NUMBER(25);
      vr_nrdconta_cre INTEGER;
      vr_cdagenci_cre INTEGER;
      vr_tpconta_cre  VARCHAR2(5);
      -- Conta Debitada
      vr_ispbif_deb   INTEGER;
      vr_nmif_deb     VARCHAR2(50);
      vr_nmcli_deb    VARCHAR2(200);
      vr_nrcpfcgc_deb VARCHAR2(20);
      vr_nrcpfcgc_deb_pesq NUMBER(25);
      vr_nrdconta_deb INTEGER;
      vr_cdagenci_deb INTEGER;
      vr_tpconta_deb  VARCHAR2(5);
      --Informações para DE -> PARA
      vr_nrdconta_cre_concil INTEGER;
      vr_cdagenci_cre_concil INTEGER;
      
      -- Dados da Transação
      vr_vlconcil  NUMBER(25,2);
      vr_vlconsul  NUMBER(25,2);
      vr_dssitmen  VARCHAR2(50);
      vr_nrcontro  VARCHAR2(20); 
      
      -- Indice da tabela de conciliacao
      vr_chave_conciliar VARCHAR2(150);
      -- Indice da tabela de processados
      vr_index_proc  VARCHAR2(110);
      -- Quantidade de Registros
      vr_nrdlinha    INTEGER;
      -- Indice das datas
      vr_index_data  VARCHAR2(10);

      -- Duplicidade
      vr_dsduplic    VARCHAR2(1);

      -- Campos para criação das criticas
      vr_cria_critica INTEGER;
      vr_conciliar    INTEGER;
      vr_dsorigem     VARCHAR2(20);
      vr_dsespeci     VARCHAR2(3);
      vr_banco_deb    INTEGER;
      vr_banco_cre    INTEGER;
      
      -- Tabelas 
      vr_tbarquivo typ_tbarquivo; -- Tabela de dados do arquivo
      vr_tbayllos  typ_tbayllos;  -- Tabela de dados do ayllos
      -- Registro de Linhas Processadas      
      vr_tbprocessados typ_tbprocessados;
      
      
      -- Cursor para identificar a Cooperativa/Agência
      CURSOR cr_crapcop IS
        SELECT crapcop.cdcooper,
               crapcop.cdagectl
          FROM crapcop;
      
      -- Cursor para identificar o log da mensagem de tansação do SPB
      CURSOR cr_craplmt(pr_dttransa IN craplmt.dttransa%TYPE) IS
        SELECT lmt.dttransa,
               lmt.hrtransa,
               lmt.nmevento,
               lmt.nrctrlif,
               lmt.vldocmto,
               -- Origem do lançamento
               DECODE(lmt.idorigem,1,'AIMARO CARACTER',
                                   2,'CAIXA ONLINE',
                                   3,'INTERNET BANK',
                                   4,'TAA',
                                   5,'AIMARO WEB',
                                   6,'URA',
                                   '') origem,
               -- Campos Cooperativa
               NVL(TRIM(lmt.cdbanctl),0) cddbanco_cop,
               NVL(TRIM(lmt.cdagectl),0) cdagenci_cop,
               NVL(TRIM(lmt.nrcpfcop),0) nrcpfcgc_cop,
               NVL(TRIM(lmt.nrdconta),0) nrdconta_cop,
               NVL(TRIM(lmt.nmcopcta),'') nmcooper_cop,
               -- Campos Outra IF
               NVL(TRIM(lmt.cdbandif),0) cddbanco_if,
               NVL(TRIM(lmt.cdagedif),0) cdagenci_if,
               NVL(TRIM(lmt.nrcpfdif),0) nrcpfcgc_if,
               NVL(TRIM(lmt.nrctadif),0) nrdconta_if,
               NVL(TRIM(lmt.nmtitdif),'') nmcooper_if
          FROM craplmt lmt
         WHERE lmt.cdcooper IN (SELECT cdcooper FROM crapcop)
           AND lmt.dttransa = pr_dttransa
           AND lmt.nmevento IN ('STR0005R2','STR0007R2','STR0008R2','STR0005',
                                'STR0037R2','STR0047R2','STR0008','STR0037',
                                'PAG0107R2','PAG0108R2','PAG0143R2','PAG0107',
                                'PAG0108','PAG0137R2','PAG0137');
      
      -- Cursor para buscar a quantidade de mensagens que existem 
      -- para o Numero de Controle IF
      CURSOR cr_craplmt_qtd(pr_nrctrlif IN craplmt.nrctrlif%TYPE) IS
        SELECT COUNT(lmt.dttransa)
          FROM craplmt lmt
         WHERE lmt.cdcooper IN (SELECT cdcooper FROM crapcop)
           AND lmt.nrctrlif = pr_nrctrlif;
      vr_qtd_lmt INTEGER;
      
      -- Cursor para buscar as informações de Teansferencia de Crédito para a JD
      CURSOR cr_gnmvspb(pr_dtmensag IN gnmvspb.dtmensag%TYPE) IS
        SELECT spb.cdcooper
              ,spb.dsmensag
              ,spb.dtmensag
              ,spb.vllanmto
              ,spb.dsinstdb
              ,spb.cdagendb
              ,NVL(TRIM(spb.dscntadb),0) dscntadb
              ,spb.nmcliedb
              ,spb.nrcnpjdb
              ,spb.dsinstcr
              ,spb.cdagencr
              ,NVL(TRIM(spb.dscntacr),0) dscntacr
              ,spb.nmcliecr
              ,spb.nrcnpjcr
          FROM gnmvspb spb
         WHERE spb.cdcooper > 0
           -- Apenas as mensagens de VR BOLETO
           AND spb.dsmensag in ('STR0026','PAG0122','STR0026R2','PAG0122R2',
                                'STR0006','STR0006R2','STR0025','PAG0121',
                                'PAG0142R2','STR0034R2','PAG0134R2')
           AND spb.dtmensag = pr_dtmensag;
      rw_gnmvspb cr_gnmvspb%ROWTYPE;
           
      -- Cursor para buscar as informações do banco
      CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
        SELECT crapban.nrispbif
          FROM crapban
         WHERE crapban.cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;
      
      -- Cursor para buscar as informações do banco - pelo número do ISPB
      CURSOR cr_crapban2 IS
        SELECT crapban.cdbccxlt
              ,crapban.nrispbif 
          FROM crapban 
         WHERE crapban.cdbccxlt > 0 
           AND crapban.nrispbif > 0;
           
      -- Cursor para buscar as informações da conta incorporada
      CURSOR cr_craptco (pr_cdcopant IN craptco.cdcopant%TYPE
                        ,pr_nrctaant IN craptco.nrctaant%TYPE) IS
        SELECT tco.nrdconta
          FROM craptco tco
         WHERE tco.cdcopant = pr_cdcopant
           AND tco.nrctaant = pr_nrctaant
           AND tco.flgativo = 1;
      rw_craptco cr_craptco%ROWTYPE;
           
      -- Mensagens de TED devolvidas
      CURSOR cr_msg_devolvida (pr_dttransa  IN DATE) IS
        SELECT spb.cdcooper
              ,spb.nrdconta
              ,spb.cdagenci
              ,spb.nrdcaixa
              ,spb.cdoperad
              ,spb.dttransa
              ,spb.hrtransa
              ,spb.cdprogra
              ,spb.nmevento
              ,spb.nrctrlif
              ,spb.vldocmto
              ,spb.cdbanco_origem
              ,spb.cdagencia_origem
              ,spb.nmtitular_origem
              ,spb.nrcpf_origem
              ,spb.cdbanco_destino
              ,spb.cdagencia_destino
              ,spb.nrconta_destino
              ,spb.nmtitular_destino
              ,spb.nrcpf_destino
              ,spb.dsmotivo_rejeicao
              ,spb.nrispbif
          FROM tbspb_trans_rejeitada spb 
         WHERE spb.dttransa = pr_dttransa;

      -- Registro de Cooperativas/Agência
      TYPE typ_tbagenci_coop IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
      vr_tbagenci_coop typ_tbagenci_coop;
      -- Registros de Bancos/ISPB
      TYPE typ_tbbanco_ispb  IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
      vr_tbbanco_ispb typ_tbbanco_ispb;
      -- Registro de Datas que existem no arquivo
      TYPE typ_dtdatas IS TABLE OF DATE INDEX BY VARCHAR2(10);
      vr_tbdatas typ_dtdatas;
      
      /* Função para remover a mascara dos campos */
      FUNCTION fn_remove_mask(pr_valor IN VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        -- Utilizar mascara padrão de conta de Nro Contrato
        RETURN REPLACE(REPLACE(REPLACE(pr_valor,'.',''),'-',''),'/','');
      END;
      
    BEGIN
      
      -- Limpar as tabelas
      pr_tbcritic.DELETE;  
      vr_tbprocessados.DELETE;
      vr_tbbanco_ispb.DELETE;
      vr_tbagenci_coop.DELETE;
      
      -- Carregar o código das cooperativas, vinculadas para cada agencia
      vr_tbagenci_coop(0):= 0;
      FOR rw_crapcop IN cr_crapcop LOOP
        vr_tbagenci_coop(rw_crapcop.cdagectl):= rw_crapcop.cdcooper;
      END LOOP;
      
      -- Carregar o código dos bancos vinculados para cada ISPB
      vr_tbbanco_ispb(0):= 1; -- ISPB zero é para o Banco do Brasil
      FOR rw_crapban2 IN cr_crapban2 LOOP
        vr_tbbanco_ispb(rw_crapban2.nrispbif):= rw_crapban2.cdbccxlt;
      END LOOP;
    
      -- Abrir o arquivos
      GENE0001.pc_abre_arquivo(pr_nmdireto => pr_nmdireto
                              ,pr_nmarquiv => pr_nmarquiv
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => vr_des_erro);
    
      -- Verifica se houve erros na abertura do arquivo
      IF vr_des_erro IS NOT NULL THEN
        vr_dscritic := 'Erro ao abrir o arquivo: '||pr_nmarquiv;
        RAISE vr_exc_erro;
      END IF;

      -- Se o arquivo estiver aberto
      IF  utl_file.IS_OPEN(vr_utlfileh) THEN
        vr_nrdlinha := 0;
        
        -- Percorrer as linhas do arquivo
        LOOP
          -- Limpa a variável que receberá a linha do arquivo
          vr_dsdlinha := NULL;
          vr_nrdlinha := vr_nrdlinha + 1;
          BEGIN         
            -- Lê a linha do arquivo
            GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh
                                        ,pr_des_text => vr_dsdlinha);
            
            -- Eliminar possíveis espaços das linhas
            vr_dsdlinha := REPLACE(REPLACE(vr_dsdlinha,chr(10),NULL),chr(13), NULL);

            -- Eliminar "&"
            vr_dsdlinha := REPLACE(vr_dsdlinha,'&','');
            -- Eliminar ">"
            vr_dsdlinha := REPLACE(vr_dsdlinha,'>','');
            -- Eliminar "<"
            vr_dsdlinha := REPLACE(vr_dsdlinha,'<','');
            -- Eliminar "'"
            vr_dsdlinha := REPLACE(vr_dsdlinha,'''','');
            -- Eliminar "
            vr_dsdlinha := REPLACE(vr_dsdlinha,'"','');
            
            -- Criando um array com todas as informações da concilição
            vr_arr_concil := gene0002.fn_quebra_string(vr_dsdlinha, ';');
            
            --Validar se o primeiro campo é o cabeçalho do arquivo
            IF UPPER(vr_arr_concil(1)) = 'GRUPO' THEN
              CONTINUE;
            END IF;
            
            -- Validar se a informacao do grupo veio
            IF TRIM(vr_arr_concil(1)) IS NULL THEN
              CONTINUE;
            END IF;

            -- Carregar a mensagem que esta sendo processada
            vr_dsmensag := TRIM(vr_arr_concil(6));
            
            -- Solicitação da área do SPB
            -- Desconsiderar tipo de mensagem STR0004 e STR0004R2, pois são mensagens que não afetam cliente
            -- Desconsiderar tipo de mensagem STR0003 e STR0003R2, pois são mensagens que não afetam cliente
            -- Desconsiderar tipo de mensagem STR0007, pois são mensagens que não afeta cliente (manter a STR0007R2, pois essa afeta)
            IF vr_dsmensag IN ('STR0004','STR0004R2','STR0003','STR0003R2','STR0007') OR
               vr_dsmensag IS NULL THEN
              CONTINUE;
            END IF;
            
            -- Conforme alinhado com o Diego, as mensagens de Portabilidade 
            -- STR0047, STR0047R1, STR0048 nao devem ser tratadas
            -- Apenas a mensagem de recebimento da STR00047R2 deve ser validada
            IF vr_dsmensag IN ('STR0047R1','STR0048') THEN
              CONTINUE;
            END IF;
            
            -- Desmontar a linha de acordo com o layout do arquivo (Os campos em branco/zeros serão ignorados
            vr_grupo    := TRIM(vr_arr_concil(1));
            vr_dtmensag := TO_DATE(vr_arr_concil(2),'DD/MM/YYYY');
            vr_hrmensag := NVL(TRIM(vr_arr_concil(3)),'00:00:00');
            vr_hrefetiv := NVL(TRIM(vr_arr_concil(4)),'00:00:00');
            vr_dsareneg := TRIM(vr_arr_concil(5));
            vr_nrmensag := TO_NUMBER(TRIM(vr_arr_concil(7)));
            vr_nrctrlif := TRIM(vr_arr_concil(8));
            -- Conta Creditada
            vr_ispbif_cre   := TO_NUMBER(TRIM(vr_arr_concil(9)));
            vr_nmif_cre     := TRIM(vr_arr_concil(10));
            vr_nmcli_cre    := TRIM(vr_arr_concil(11));
            vr_nrcpfcgc_cre := NVL(TRIM(vr_arr_concil(12)),'');
            vr_nrcpfcgc_cre_pesq := NVL(TRIM(fn_remove_mask(vr_nrcpfcgc_cre)),0);
            vr_nrdconta_cre := TO_NUMBER(NVL(TRIM(vr_arr_concil(13)),0));
            vr_cdagenci_cre := TO_NUMBER(NVL(TRIM(vr_arr_concil(14)),0));
            vr_tpconta_cre  := TRIM(vr_arr_concil(15));
            -- Conta Debitada
            vr_ispbif_deb   := TO_NUMBER(TRIM(vr_arr_concil(16)));
            vr_nmif_deb     := TRIM(vr_arr_concil(17));
            vr_nmcli_deb    := TRIM(vr_arr_concil(18));
            vr_nrcpfcgc_deb := NVL(TRIM(vr_arr_concil(19)),'');
            vr_nrcpfcgc_deb_pesq:= NVL(TRIM(fn_remove_mask(vr_nrcpfcgc_deb)),0);
            vr_nrdconta_deb := TO_NUMBER(NVL(TRIM(vr_arr_concil(20)),0));
            vr_cdagenci_deb := TO_NUMBER(NVL(TRIM(vr_arr_concil(21)),0));
            vr_tpconta_deb  := TRIM(vr_arr_concil(22));
            
            -- Conversão do valor que deve ser conciliado
            BEGIN
              -- Buscar o valor da linha com a formatação de milhares e decimais
              vr_vlconcil  := TO_NUMBER(TRIM(vr_arr_concil(23)),'FM9G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
            EXCEPTION
              WHEN OTHERS THEN
                BEGIN 
                  -- Se ocorrer erro, busca o valor da linha sem a formatação de milhares e decimais
                  vr_vlconcil  := TO_NUMBER(TRIM(vr_arr_concil(23)),'FM9G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=.,');
                EXCEPTION 
                  WHEN OTHERS THEN
                    BEGIN 
                      -- Se ocorrer erro, busca o valor da linha sem a formatação de milhares e decimais
                      vr_vlconcil  := TO_NUMBER(TRIM(vr_arr_concil(23)));
                    EXCEPTION 
                      WHEN OTHERS THEN
                        -- Caso ocorra erro novamente, exibimos o erro com o valor e a linha com problema
                        vr_dscritic := GENE0007.fn_convert_db_web('Erro na formatação do valor: ' || vr_arr_concil(23) ||
                                                                  ' na linha ' || vr_nrdlinha);
                        RAISE vr_exc_erro;
                    END;
                END;
            END;
              
            -- Dados da Transação
            vr_vlconsul  := ABS(vr_vlconcil);
            vr_dssitmen  := TRIM(vr_arr_concil(26));
            vr_nrcontro  := TRIM(vr_arr_concil(27));
            
            -- Dados do arquivo -> Padrao ira utilizar agencia e conta que estao no arquivo
            vr_nrdconta_cre_concil := vr_nrdconta_cre;
            vr_cdagenci_cre_concil := vr_cdagenci_cre;
            
            -- INICIO - Validacao para DE -> PARA daa Transulcred -> Transpocred
            -- Agencia Creditada eh a Transulcred 
            IF vr_cdagenci_cre = 116 THEN
              -- Data da mensagem eh entre o periodo de 01/01/2017 e 21/03/2017
              IF vr_dtmensag >= to_date('01/01/2017','DD/MM/YYYY') AND
                 vr_dtmensag <= to_date('21/03/2017','DD/MM/YYYY') THEN
                
                -- SE status for "efetivado", será feito o DE-> PARA
                -- mensagens devolvidas ou rejeitadas não irão possuir DE -> PARA
                IF UPPER(vr_dssitmen) LIKE UPPER('%EFETIVADO%') THEN
                  -- Buscamos a conta nova 
                  OPEN cr_craptco (pr_cdcopant => 17 -- Transulcred
                                  ,pr_nrctaant => vr_nrdconta_cre);
                  FETCH cr_craptco INTO rw_craptco;
                  -- Encontrou a conta incorporada
                  IF cr_craptco%FOUND THEN
                    -- Se encontrou a conta incorporada, utilizamos a conta nova para montar a chave de conciliacao
                    vr_nrdconta_cre_concil := rw_craptco.nrdconta;
                    vr_cdagenci_cre_concil := 108; -- Transpocred
                  END IF;
                  -- Fecha cursor
                  CLOSE cr_craptco;
                END IF;
              END IF;
            END IF;
            -- FIM - Validacao para DE -> PARA daa Transulcred -> Transpocred
            
            -- Armazenar a data da mensagem
            vr_tbdatas(TO_CHAR(vr_dtmensag,'DDMMRRRR')) := vr_dtmensag;

            vr_banco_deb:= 0;
            vr_banco_cre:= 0;

            -- Buscar o codigo do Banco Debitado
            IF vr_tbbanco_ispb.exists(vr_ispbif_deb) THEN
              vr_banco_deb:= vr_tbbanco_ispb(vr_ispbif_deb);
            END IF;
            
            -- Buscar o codigo do Banco Creditado
            IF vr_tbbanco_ispb.exists(vr_ispbif_cre) THEN
              vr_banco_cre:= vr_tbbanco_ispb(vr_ispbif_cre);
            END IF;
            -- Indice das linhas que foram processadas
            vr_index_proc:= 'ARQUIVO'                       || -- Identificacao Arquivo JD
                            TO_CHAR(vr_ispbif_deb)          || -- Banco Debitada
                            TO_CHAR(vr_cdagenci_deb)        || -- Agencia Debitada
                            TO_CHAR(vr_nrdconta_deb)        || -- Conta Debitada
                            TO_CHAR(vr_nrcpfcgc_deb_pesq)   || -- CPF/CNPJ Debitado
                            TO_CHAR(vr_ispbif_cre)          || -- Banco Creditado
                            TO_CHAR(vr_cdagenci_cre_concil) || -- Agencia Creditada 
                            TO_CHAR(vr_nrdconta_cre_concil) || -- Conta Creditada
                            TO_CHAR(vr_nrcpfcgc_cre_pesq)   || -- CPF/CNPJ Creditado
                            TO_CHAR(vr_vlconsul * 100);        -- Valor (MULTIPLICAR POR 100 PARA TIRAR DECIMAIS)
                             
            -- Verificar se a opcao eh para listar apenas as duplicidades
            IF pr_dsdopcao = 'OI' THEN
              -- Verifica Duplicidade do arquivo
              vr_dsduplic:= 'N';
              IF vr_tbprocessados.EXISTS(vr_index_proc) THEN
                vr_dsduplic:= 'S';
              ELSE
                -- Armazena a linha processada
                vr_tbprocessados(vr_index_proc).nrdlinha := pr_tbcritic.COUNT() + 1;
                vr_tbprocessados(vr_index_proc).dsduplic := 'N';
                vr_tbprocessados(vr_index_proc).cddotipo := vr_dsmensag;
                vr_tbprocessados(vr_index_proc).nrcontro := vr_nrcontro;
                vr_tbprocessados(vr_index_proc).nrctrlif := vr_nrctrlif;
                vr_tbprocessados(vr_index_proc).vlconcil := vr_vlconcil;
                vr_tbprocessados(vr_index_proc).dtmensag := to_char(vr_dtmensag,'DD/MM/RRRR');
                vr_tbprocessados(vr_index_proc).dsdahora := vr_hrmensag;
                vr_tbprocessados(vr_index_proc).dsorigem := vr_dsorigem;
                vr_tbprocessados(vr_index_proc).dsespeci := vr_dsespeci;
                -- Dados Conta Debitada
                vr_tbprocessados(vr_index_proc).cddbanco_deb := vr_banco_deb;
                vr_tbprocessados(vr_index_proc).cdagenci_deb := vr_cdagenci_deb;
                vr_tbprocessados(vr_index_proc).nrdconta_deb := vr_nrdconta_deb;
                vr_tbprocessados(vr_index_proc).nrcpfcgc_deb := vr_nrcpfcgc_deb;
                vr_tbprocessados(vr_index_proc).nmcooper_deb := vr_nmcli_deb;
                -- Dados Conta Creditada
                vr_tbprocessados(vr_index_proc).cddbanco_cre := vr_banco_cre;
                vr_tbprocessados(vr_index_proc).cdagenci_cre := vr_cdagenci_cre;
                vr_tbprocessados(vr_index_proc).nrdconta_cre := vr_nrdconta_cre;
                vr_tbprocessados(vr_index_proc).nrcpfcgc_cre := vr_nrcpfcgc_cre;
                vr_tbprocessados(vr_index_proc).nmcooper_cre := vr_nmcli_cre; 
                vr_tbprocessados(vr_index_proc).dsorigemerro := 'ARQUIVO JD';
              END IF;
              
              -- Zerar os identificadores de criação do  erro
              vr_cria_critica:= 0; --> Identifica a geração da Crítica
              vr_conciliar   := 0; --> Identifica se a linha deve ser armazenada para conciliar
              -- verificar se eh duplicado
              IF vr_dsduplic = 'S' THEN
                vr_cria_critica:= 1;
                -- verificar o registro jah foi adicionado as criticas
                IF vr_tbprocessados(vr_index_proc).dsduplic != 'S' THEN
                  -- Se nao existir 
                  -- Atualiza o duplicado
                  vr_tbprocessados(vr_index_proc).dsduplic := 'S';
                  -- Se estiver com critica apenas armazena o original
                  vr_chave_conciliar:= vr_index_proc || to_char(pr_tbcritic.COUNT() + 1);
                  pr_tbcritic(vr_chave_conciliar) := vr_tbprocessados(vr_index_proc);
                END IF;
                -- gerar a chave para gerar o duplicado
                vr_chave_conciliar:= vr_index_proc || to_char(pr_tbcritic.COUNT() + 1);
              END IF;
            ELSE
              -- Realiza a conciliacao 
              -- Indice para identificação das criticas PADRAO
              vr_chave_conciliar:= TO_CHAR(vr_nrcontro)            || -- Numero de Controle
                                   TO_CHAR(vr_cdagenci_deb)        || -- Agencia Debitada
                                   TO_CHAR(vr_nrdconta_deb)        || -- Conta Debitada
                                   TO_CHAR(vr_nrcpfcgc_deb_pesq)   || -- CPF/CNPJ Debitado
                                   TO_CHAR(vr_cdagenci_cre_concil) || -- Agencia Creditada 
                                   TO_CHAR(vr_nrdconta_cre_concil) || -- Conta Creditada
                                   TO_CHAR(vr_nrcpfcgc_cre_pesq)   || -- CPF/CNPJ Creditado
                                   TO_CHAR(vr_vlconsul * 100);        -- Valor 
                              
              
              -- Verifica se a duplicidade existe
              IF vr_dsduplic = 'S' THEN
                -- Se o registro já foi adicionado como erro
                -- Apenas atualiza a situação para duplicado, e processa a próxima linha
                IF pr_tbcritic.EXISTS(vr_chave_conciliar) THEN
                  -- Duplicado 
                  pr_tbcritic(vr_chave_conciliar).dsduplic:= 'S';
                  -- Passa para a proxima linha
                  CONTINUE;
                END IF;
              END IF;
              
              -- Zerar os identificadores de criação do  erro
              vr_cria_critica:= 0; --> Identifica a geração da Crítica
              vr_conciliar   := 1; --> Identifica se a linha deve ser armazenada para conciliar
              
              -- Criticar qualquer mensagem recebida com esta nomenclatura, independente de status. 
              -- Ayllos não realiza o crédito desta TED automaticamente
              IF vr_dsmensag IN ('STR0025R2','STR0029R2','STR0034R2','STR0040R2',
                                 'PAG0121R2','PAG0134R2') THEN
                -- Sempre gerar crítica
                vr_cria_critica := 1;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
              
              -- Não enviamos, não será necessário tratamento. 
              -- Portanto, qualquer lançamento com esta nomenclatura, 
              -- independente de status, criticar em relatório!
              ELSIF vr_dsmensag IN('STR0029','STR0034','STR0040','STR0048',
                                   'PAG0134','PAG0143') THEN 
                -- Sempre gerar crítica
                vr_cria_critica := 1;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
                
              -- Como sistema não tem como validar envios de portabilidade que são efetivados apenas no CTC, 
              -- criticar qualquer mensagem com esta nomenclatura, indiferente de status.
              ELSIF vr_dsmensag IN('STR0048R2') THEN 
                -- Sempre gerar crítica
                vr_cria_critica := 1;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
                
              -- Mensagem é enviada através do Caixa Online. 
              -- Conciliar lançamento JD com lançamento em espécie (não movimenta conta corrente). 
              -- Apontar diferença se status "devolvido", "rejeitado Bacen", "rejeitado CIP".
              ELSIF vr_dsmensag IN('STR0005','PAG0107') THEN 
                IF UPPER(vr_dssitmen) LIKE UPPER('%REJEITADO%') OR
                   UPPER(vr_dssitmen) LIKE UPPER('%DEVOLVIDO%') THEN
                  -- Gerar crícia pois o lançamento em espécie foi devolvido/rejeitado
                  vr_cria_critica := 1;           
                END IF;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
                
              -- Mensagem eh enviada atraves do CTC e SPB da JD. 
              -- Portanto, qualquer lançamento com esta nomenclatura, 
              -- SE status diferente de "efetivado", criticar em relatorio!
              ELSIF vr_dsmensag IN('STR0047') THEN 
                IF UPPER(vr_dssitmen) NOT LIKE UPPER('%EFETIVADO%') THEN
                  -- Gerar crícia pois o lançamento em espécie foi devolvido/rejeitado
                  vr_cria_critica := 1;           
                END IF;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
                
              -- Sistema deverá identificar qual o número de controle da TED original (TED origem efetivada)
              -- para validar qual a conta corrente a ser creditada a devolução.
              -- Validar os campos: IF, Valor e Número de Controle Original 
              ELSIF vr_dsmensag IN('STR0010R2','PAG0111R2') THEN 
                          
                -- Verificar se o Numero de Controle IF esta disponivel
                IF TRIM(vr_nrctrlif) IS NULL THEN
                  -- Se nao possui numero de controle IF, gerar critica
                  vr_cria_critica:= 1;
                ELSE
                  -- Se existir o numero de controle busca a quantidade de lancamento
                  OPEN cr_craplmt_qtd(pr_nrctrlif => vr_nrctrlif);
                  FETCH cr_craplmt_qtd INTO vr_qtd_lmt;
                  CLOSE cr_craplmt_qtd;
                  IF vr_qtd_lmt <> 2 THEN
                    -- Nao identificou nenhum lancamento com esse numero de controle
                    vr_cria_critica:= 1;
                  END IF;
                END IF;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;

              -- Sistema credita estes tipos de TED automaticamente. 
              -- Validar os campos: Agência, Conta Corrente, CPF/CNPJ e Valor
              ELSIF vr_dsmensag IN('STR0005R2','STR0007R2','STR0008R2',
                                   'PAG0107R2','PAG0108R2','PAG0143R2') THEN 
                
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_cre_concil) || '_' || 
                                     TO_CHAR(vr_nrdconta_cre_concil) || '_' ||
                                     TO_CHAR(vr_nrcpfcgc_cre_pesq)   || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);


              -- Validar se a mensagem pertence ao VR BOLETO
              ELSIF vr_dsmensag IN('STR0026','PAG0122') THEN 

                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                -- Quando VR BOLETO, validar apenas se existe o registro na gnmvspb
                -- VR BOLETO enviado
                vr_chave_conciliar:= TO_CHAR(vr_nrcpfcgc_deb_pesq) || '_' || 
                                     TO_CHAR(vr_nrcpfcgc_cre_pesq) || '_' || 
                                     TO_CHAR(vr_dsmensag) || '_' ||
                                     TO_CHAR(vr_dtmensag,'DDMMRRRR') || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);
            
              -- Validar se a mensagem pertence ao RETORNO de VR BOLETO
              ELSIF vr_dsmensag IN('STR0026R2','PAG0122R2') THEN 
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                -- Quando VR BOLETO, validar apenas se existe o registro na gnmvspb
                -- VR BOLETO recebido
                vr_chave_conciliar:= TO_CHAR(vr_nrcpfcgc_cre_pesq) || '_' || 
                                     TO_CHAR(vr_nrcpfcgc_deb_pesq) || '_' || 
                                     TO_CHAR(vr_dsmensag) || '_' ||
                                     TO_CHAR(vr_dtmensag,'DDMMRRRR') || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);

              -- Sistema credita estes tipos de TED automaticamente. 
              -- Validar os campos: Agência, Conta Corrente, CPF/CNPJ (debitado) e Valor
              ELSIF vr_dsmensag IN('STR0037R2','PAG0137R2') THEN 
                      
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_cre_concil) || '_' || 
                                     TO_CHAR(vr_nrdconta_cre_concil) || '_' ||
                                     TO_CHAR(vr_nrcpfcgc_deb_pesq)   || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);
              
              -- TED por esta finalidade não credita automaticamente a conta corrente. 
              -- Validar os campos: Agência, Conta Corrente, Valor
              ELSIF vr_dsmensag IN('STR0006') THEN 
                      
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_deb) || '_' || 
                                     TO_CHAR(vr_nrdconta_deb) || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);
              
              -- TED por esta finalidade não credita automaticamente a conta corrente. 
              -- Validar os campos: Numero de Controle STR/PAG, Valor
              ELSIF vr_dsmensag IN('STR0006R2','STR0025R2','STR0034R2',
                                   'PAG0121R2','PAG0142R2','PAG0134R2') THEN 
                      
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     vr_nrcontro || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);
                                     
              -- Mensagem é enviada através da Cabine JD.
              -- Validar os campos: Agência, Conta Corrente, Valor
              ELSIF vr_dsmensag IN('STR0025','PAG0121') THEN 
                      
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_deb) || '_' || 
                                     TO_CHAR(vr_nrdconta_deb) || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);

              -- Mensagem de Recebimento da Portabilidade
              -- Validar recebimento de crédito na JD com lançamento de portabilidade no Ayllos 
              -- (tratamento diferente das TEDs). 
              -- Criticar caso não encontre lançamento no sistema ou se status "devolvido"
              ELSIF vr_dsmensag IN('STR0047R2') THEN 
                
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                -- Não validar o CPF/Agencia Debitados
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_nrdconta_deb)        || '_' || -- Conta Debitada
                                     TO_CHAR(vr_cdagenci_cre_concil) || '_' || -- Agencia Creditada
                                     TO_CHAR(vr_nrdconta_cre_concil) || '_' || -- Conta Creditada
                                     TO_CHAR(vr_nrcpfcgc_cre_pesq)   || '_' || -- CPF/CNPJ Creditado
                                     TO_CHAR(vr_ispbif_deb)          || '_' || -- ISPB IF Debitada
                                     TO_CHAR(vr_vlconsul * 100);               -- Valor do Documento
                
              -- Mensagem eh enviada atraves da internet, mobile e caixa online. 
              -- Conciliar lançamento JD com lançamento em especie/conta corrente/LOGSPB. 
              -- Validar status!
              ELSIF vr_dsmensag IN('STR0008','PAG0108') THEN 
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                -- Não validar o CPF/Agencia Debitados
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_deb) || '_' || -- Agencia Debitada
                                     TO_CHAR(vr_nrdconta_deb) || '_' || -- Conta Debitada
                                     TO_CHAR(vr_nrcpfcgc_deb_pesq) || '_' || -- CPF/CNPJ Debitado
                                     TO_CHAR(vr_vlconsul * 100); -- Valor do Documento
              
              -- Mensagem de TEC salario, eh enviada via IB/Ayllos. 
              -- Conciliar lancamento JD com lancamento gravado no Ayllos (LOGSPB). 
              -- Apontar diferenca se status "devolvido", "rejeitado Bacen"...
              ELSIF vr_dsmensag IN('STR0037','PAG0137') THEN 
                
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Validar os campos: Agência, Conta Corrente, CPF/CNPJ e Valor
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_deb) || '_' || -- Agencia Debitada
                                     TO_CHAR(vr_nrdconta_deb) || '_' || -- Conta Debitada
                                     TO_CHAR(vr_nrcpfcgc_deb_pesq) || '_' || -- CPF/CNPJ Debitado
                                     TO_CHAR(vr_vlconsul * 100); -- Valor do Documento

              -- Mensagens de devolução
              ELSIF vr_dsmensag IN('STR0010','PAG0111','STR0048') THEN 
              
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Validar os campos: Numero de controle IF, Valor
                vr_chave_conciliar:= vr_dsmensag || '_' ||-- Mensagem
                                     vr_nrctrlif || '_' ||  -- Numero de Controle
                                     TO_CHAR(vr_vlconsul * 100); -- Valor do Documento
              END IF;
            END IF; -- Fim da Duplicidade
              
            -- Gerar a critica 
            IF vr_cria_critica = 1 THEN
              -- Gerar a critica com os valores identificados em um dos tipos...
              pr_tbcritic(vr_chave_conciliar).nrdlinha := vr_nrdlinha;
              pr_tbcritic(vr_chave_conciliar).dsduplic := vr_dsduplic;
              pr_tbcritic(vr_chave_conciliar).cddotipo := vr_dsmensag;
              pr_tbcritic(vr_chave_conciliar).nrcontro := vr_nrcontro;
              pr_tbcritic(vr_chave_conciliar).nrctrlif := vr_nrctrlif;
              pr_tbcritic(vr_chave_conciliar).vlconcil := vr_vlconcil;
              pr_tbcritic(vr_chave_conciliar).dtmensag := to_char(vr_dtmensag,'DD/MM/RRRR');
              pr_tbcritic(vr_chave_conciliar).dsdahora := vr_hrmensag;
              pr_tbcritic(vr_chave_conciliar).dsorigem := vr_dsorigem;
              pr_tbcritic(vr_chave_conciliar).dsespeci := vr_dsespeci;
              -- Dados Conta Debitada
              pr_tbcritic(vr_chave_conciliar).cddbanco_deb := vr_banco_deb;
              pr_tbcritic(vr_chave_conciliar).cdagenci_deb := vr_cdagenci_deb;
              pr_tbcritic(vr_chave_conciliar).nrdconta_deb := vr_nrdconta_deb;
              pr_tbcritic(vr_chave_conciliar).nrcpfcgc_deb := vr_nrcpfcgc_deb;
              pr_tbcritic(vr_chave_conciliar).nmcooper_deb := vr_nmcli_deb;
              -- Dados Conta Creditada
              pr_tbcritic(vr_chave_conciliar).cddbanco_cre := vr_banco_cre;
              pr_tbcritic(vr_chave_conciliar).cdagenci_cre := vr_cdagenci_cre;
              pr_tbcritic(vr_chave_conciliar).nrdconta_cre := vr_nrdconta_cre;
              pr_tbcritic(vr_chave_conciliar).nrcpfcgc_cre := vr_nrcpfcgc_cre;
              pr_tbcritic(vr_chave_conciliar).nmcooper_cre := vr_nmcli_cre; 
              pr_tbcritic(vr_chave_conciliar).dsorigemerro := 'ARQUIVO JD';
            END IF;
              
            -- Adicionar as linhas do arquivo que devem ser conciliadas
            IF vr_conciliar = 1 THEN
               -- Verificar se o indice que geramos ja foi processado
              IF vr_tbarquivo.EXISTS(vr_chave_conciliar) THEN
                vr_tbarquivo(vr_chave_conciliar).dsduplic := 'S';
              ELSE
                -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
                vr_tbarquivo(vr_chave_conciliar).nrdlinha := vr_nrdlinha;
                vr_tbarquivo(vr_chave_conciliar).dsduplic := vr_dsduplic;
                vr_tbarquivo(vr_chave_conciliar).cddotipo := vr_dsmensag;
                vr_tbarquivo(vr_chave_conciliar).nrcontro := vr_nrcontro;
                vr_tbarquivo(vr_chave_conciliar).nrctrlif := vr_nrctrlif;
                vr_tbarquivo(vr_chave_conciliar).vlconcil := vr_vlconcil;
                vr_tbarquivo(vr_chave_conciliar).dtmensag := to_char(vr_dtmensag,'DD/MM/RRRR');
                vr_tbarquivo(vr_chave_conciliar).dsdahora := vr_hrmensag;
                -- Dados Conta Debitada
                vr_tbarquivo(vr_chave_conciliar).cddbanco_deb := vr_banco_deb;
                vr_tbarquivo(vr_chave_conciliar).cdagenci_deb := vr_cdagenci_deb;
                vr_tbarquivo(vr_chave_conciliar).nrdconta_deb := vr_nrdconta_deb;
                vr_tbarquivo(vr_chave_conciliar).nrcpfcgc_deb := vr_nrcpfcgc_deb;
                vr_tbarquivo(vr_chave_conciliar).nmcooper_deb := vr_nmcli_deb;
                -- Dados Conta Creditada
                vr_tbarquivo(vr_chave_conciliar).cddbanco_cre := vr_banco_cre;
                vr_tbarquivo(vr_chave_conciliar).cdagenci_cre := vr_cdagenci_cre;
                vr_tbarquivo(vr_chave_conciliar).nrdconta_cre := vr_nrdconta_cre;
                vr_tbarquivo(vr_chave_conciliar).nrcpfcgc_cre := vr_nrcpfcgc_cre;
                vr_tbarquivo(vr_chave_conciliar).nmcooper_cre := vr_nmcli_cre; 
                vr_tbarquivo(vr_chave_conciliar).dsorigemerro := 'ARQUIVO JD';
              END IF;
            END IF;
            
          EXCEPTION
            WHEN no_data_found THEN
              -- Acabou a leitura, então finaliza o loop
              EXIT;
          END;
          
        END LOOP; -- Finaliza o loop das linhas do arquivo
        
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
      END IF;

      -- Se não houverem dados no registro de memória
      IF vr_tbarquivo.COUNT() = 0 AND vr_tbprocessados.COUNT() = 0 THEN
        vr_dscritic := GENE0007.fn_convert_db_web('Dados não encontrados no arquivo.');
        RAISE vr_exc_erro;
      END IF;
    
      ------------------ CARREGAR AS INFORMACOES DAS TEDS QUE EXISTEM NO AYLLOS ------------------
      -- Buscar a primeira data das mensagens
      vr_index_data := vr_tbdatas.FIRST;
      -- Enquanto existir data, continua o processo
      WHILE vr_index_data IS NOT NULL LOOP
        vr_chave_conciliar := '';
        vr_dtmensag := vr_tbdatas(vr_index_data);
        -- Carregar todos os registros de LMT para a data
        FOR rw_craplmt IN cr_craplmt(pr_dttransa => vr_dtmensag) LOOP
          vr_dsmensag:= rw_craplmt.nmevento;
          
          -- Sistema credita estes tipos de TED automaticamente. 
          -- Validar os campos: Agência, Conta Corrente, CPF/CNPJ e Valor
          IF vr_dsmensag IN('STR0005R2','STR0007R2','STR0008R2',
                            'PAG0107R2','PAG0108R2','PAG0143R2') THEN 
                
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            vr_chave_conciliar:= vr_dsmensag || '_' ||
                                 TO_CHAR(rw_craplmt.cdagenci_cop) || '_' || 
                                 TO_CHAR(rw_craplmt.nrdconta_cop) || '_' ||
                                 TO_CHAR(rw_craplmt.nrcpfcgc_cop) || '_' ||
                                 TO_CHAR(rw_craplmt.vldocmto * 100);
                                 
            -- Dados Conta Debitada
            vr_banco_deb    := rw_craplmt.cddbanco_if;
            vr_cdagenci_deb := rw_craplmt.cdagenci_if;
            vr_nrdconta_deb := rw_craplmt.nrdconta_if;
            vr_nrcpfcgc_deb := rw_craplmt.nrcpfcgc_if;
            vr_nmcli_deb    := rw_craplmt.nmcooper_if;
            -- Dados Conta Creditada
            vr_banco_cre    := rw_craplmt.cddbanco_cop;
            vr_cdagenci_cre := rw_craplmt.cdagenci_cop;
            vr_nrdconta_cre := rw_craplmt.nrdconta_cop;
            vr_nrcpfcgc_cre := rw_craplmt.nrcpfcgc_cop;
            vr_nmcli_cre    := rw_craplmt.nmcooper_cop;


          -- Mensagem é enviada através do Caixa Online. 
          -- Conciliar lançamento JD com lançamento em espécie (não movimenta conta corrente). 
          -- Apontar diferença se status "devolvido", "rejeitado Bacen", "rejeitado CIP".
          ELSIF vr_dsmensag IN('STR0005','PAG0107') THEN 
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            vr_chave_conciliar:= vr_dsmensag || '_' ||
                                 TO_CHAR(rw_craplmt.nrctrlif) || '_' ||
                                 TO_CHAR(rw_craplmt.vldocmto * 100);

            -- Dados Conta Debitada
            vr_banco_deb    := rw_craplmt.cddbanco_cop;
            vr_cdagenci_deb := rw_craplmt.cdagenci_cop;
            vr_nrdconta_deb := rw_craplmt.nrdconta_cop;
            vr_nrcpfcgc_deb := rw_craplmt.nrcpfcgc_cop;
            vr_nmcli_deb    := rw_craplmt.nmcooper_cop;
            -- Dados Conta Creditada
            vr_banco_cre    := rw_craplmt.cddbanco_if;
            vr_cdagenci_cre := rw_craplmt.cdagenci_if;
            vr_nrdconta_cre := rw_craplmt.nrdconta_if;
            vr_nrcpfcgc_cre := rw_craplmt.nrcpfcgc_if;
            vr_nmcli_cre    := rw_craplmt.nmcooper_if;

          -- Sistema credita estes tipos de TED automaticamente. 
          -- Validar os campos: Agência, Conta Corrente, CPF/CNPJ (debitado) e Valor
          ELSIF vr_dsmensag IN('STR0037R2','PAG0137R2') THEN 
                      
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            vr_chave_conciliar:= vr_dsmensag || '_' ||
                                 TO_CHAR(rw_craplmt.cdagenci_cop) || '_' || 
                                 TO_CHAR(rw_craplmt.nrdconta_cop) || '_' ||
                                 TO_CHAR(rw_craplmt.nrcpfcgc_if) || '_' ||
                                 TO_CHAR(rw_craplmt.vldocmto * 100);

            -- Dados Conta Debitada
            vr_banco_deb    := rw_craplmt.cddbanco_if;
            vr_cdagenci_deb := rw_craplmt.cdagenci_if;
            vr_nrdconta_deb := rw_craplmt.nrdconta_if;
            vr_nrcpfcgc_deb := rw_craplmt.nrcpfcgc_if;
            vr_nmcli_deb    := rw_craplmt.nmcooper_if;
            -- Dados Conta Creditada
            vr_banco_cre    := rw_craplmt.cddbanco_cop;
            vr_cdagenci_cre := rw_craplmt.cdagenci_cop;
            vr_nrdconta_cre := rw_craplmt.nrdconta_cop;
            vr_nrcpfcgc_cre := rw_craplmt.nrcpfcgc_cop;
            vr_nmcli_cre    := rw_craplmt.nmcooper_cop;

          -- Mensagem de Recebimento da Portabilidade
          -- Validar recebimento de crédito na JD com lançamento de portabilidade no Ayllos 
          -- (tratamento diferente das TEDs). 
          -- Criticar caso não encontre lançamento no sistema ou se status "devolvido"
          ELSIF vr_dsmensag IN('STR0047R2') THEN 
            -- Buscar o numero do ISPB
            OPEN cr_crapban(pr_cdbccxlt => rw_craplmt.cddbanco_cop);
            FETCH cr_crapban INTO rw_crapban;
            IF cr_crapban%FOUND THEN
              vr_ispbif_deb := rw_crapban.nrispbif;
            ELSE 
              vr_ispbif_deb := 0;
            END IF;
            -- Fecha o cursor
            CLOSE cr_crapban;
                
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            -- Não validar o CPF/Agencia Debitados
            vr_chave_conciliar:= vr_dsmensag || '_' ||
                                 TO_CHAR(rw_craplmt.nrdconta_if) || '_' || -- Conta Debitada
                                 TO_CHAR(rw_craplmt.cdagenci_cop) || '_' || -- Agencia Creditada
                                 TO_CHAR(rw_craplmt.nrdconta_cop) || '_' || -- Conta Creditada
                                 TO_CHAR(rw_craplmt.nrcpfcgc_cop) || '_' || -- CPF/CNPJ Creditado
                                 TO_CHAR(vr_ispbif_deb) || '_' || -- ISPB IF Debitada
                                 TO_CHAR(rw_craplmt.vldocmto * 100); -- Valor do Documento

            -- Dados Conta Debitada
            vr_banco_deb    := rw_craplmt.cddbanco_if;
            vr_cdagenci_deb := rw_craplmt.cdagenci_if;
            vr_nrdconta_deb := rw_craplmt.nrdconta_if;
            vr_nrcpfcgc_deb := rw_craplmt.nrcpfcgc_if;
            vr_nmcli_deb    := rw_craplmt.nmcooper_if;
            -- Dados Conta Creditada
            vr_banco_cre    := rw_craplmt.cddbanco_cop;
            vr_cdagenci_cre := rw_craplmt.cdagenci_cop;
            vr_nrdconta_cre := rw_craplmt.nrdconta_cop;
            vr_nrcpfcgc_cre := rw_craplmt.nrcpfcgc_cop;
            vr_nmcli_cre    := rw_craplmt.nmcooper_cop;

          -- Mensagem eh enviada atraves da internet, mobile e caixa online. 
          -- Conciliar lançamento JD com lançamento em especie/conta corrente/LOGSPB. 
          -- Validar status!
          ELSIF vr_dsmensag IN('STR0008','PAG0108') THEN 
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            -- Não validar o CPF/Agencia Debitados
            vr_chave_conciliar:= vr_dsmensag || '_' ||
                                 TO_CHAR(rw_craplmt.cdagenci_cop) || '_' || -- Agencia Debitada
                                 TO_CHAR(rw_craplmt.nrdconta_cop) || '_' || -- Conta Debitada
                                 TO_CHAR(rw_craplmt.nrcpfcgc_cop) || '_' || -- CPF/CNPJ Debitado
                                 TO_CHAR(rw_craplmt.vldocmto  * 100); -- Valor do Documento

            -- Dados Conta Debitada
            vr_banco_deb    := rw_craplmt.cddbanco_cop;
            vr_cdagenci_deb := rw_craplmt.cdagenci_cop;
            vr_nrdconta_deb := rw_craplmt.nrdconta_cop;
            vr_nrcpfcgc_deb := rw_craplmt.nrcpfcgc_cop;
            vr_nmcli_deb    := rw_craplmt.nmcooper_cop;
            -- Dados Conta Creditada
            vr_banco_cre    := rw_craplmt.cddbanco_if;
            vr_cdagenci_cre := rw_craplmt.cdagenci_if;
            vr_nrdconta_cre := rw_craplmt.nrdconta_if;
            vr_nrcpfcgc_cre := rw_craplmt.nrcpfcgc_if;
            vr_nmcli_cre    := rw_craplmt.nmcooper_if;
            
          -- Mensagem de TEC salario, eh enviada via IB/Ayllos. 
          -- Conciliar lancamento JD com lancamento gravado no Ayllos (LOGSPB). 
          -- Apontar diferenca se status "devolvido", "rejeitado Bacen"...
          ELSIF vr_dsmensag IN('STR0037','PAG0137') THEN 
                
            -- Validar os campos: Agência, Conta Corrente, CPF/CNPJ e Valor
            vr_chave_conciliar:= vr_dsmensag || '_' ||
                                 TO_CHAR(rw_craplmt.cdagenci_cop) || '_' || -- Agencia Debitada
                                 TO_CHAR(rw_craplmt.nrdconta_cop) || '_' || -- Conta Debitada
                                 TO_CHAR(rw_craplmt.nrcpfcgc_cop) || '_' || -- CPF/CNPJ Debitado
                                 TO_CHAR(rw_craplmt.vldocmto  * 100); -- Valor do Documento

            -- Dados Conta Debitada
            vr_banco_deb    := rw_craplmt.cddbanco_cop;
            vr_cdagenci_deb := rw_craplmt.cdagenci_cop;
            vr_nrdconta_deb := rw_craplmt.nrdconta_cop;
            vr_nrcpfcgc_deb := rw_craplmt.nrcpfcgc_cop;
            vr_nmcli_deb    := rw_craplmt.nmcooper_cop;
            -- Dados Conta Creditada
            vr_banco_cre    := rw_craplmt.cddbanco_if;
            vr_cdagenci_cre := rw_craplmt.cdagenci_if;
            vr_nrdconta_cre := rw_craplmt.nrdconta_if;
            vr_nrcpfcgc_cre := rw_craplmt.nrcpfcgc_if;
            vr_nmcli_cre    := rw_craplmt.nmcooper_if;
            
          -- TED por esta finalidade não credita automaticamente a conta corrente. 
          -- Validar os campos: Numero de Controle STR/PAG, Valor
          ELSIF vr_dsmensag IN('STR0025R2','PAG0121R2','PAG0142R2') THEN 
            vr_chave_conciliar:= vr_dsmensag || '_' ||
                                 TO_CHAR(rw_craplmt.nrctrlif) || '_' || -- Numer de Controle STR/PAG
                                 TO_CHAR(rw_craplmt.vldocmto  * 100); -- Valor do Documento

            -- Dados Conta Debitada
            vr_banco_deb    := rw_craplmt.cddbanco_if;
            vr_cdagenci_deb := rw_craplmt.cdagenci_if;
            vr_nrdconta_deb := rw_craplmt.nrdconta_if;
            vr_nrcpfcgc_deb := rw_craplmt.nrcpfcgc_if;
            vr_nmcli_deb    := rw_craplmt.nmcooper_if;
            -- Dados Conta Creditada
            vr_banco_cre    := rw_craplmt.cddbanco_cop;
            vr_cdagenci_cre := rw_craplmt.cdagenci_cop;
            vr_nrdconta_cre := rw_craplmt.nrdconta_cop;
            vr_nrcpfcgc_cre := rw_craplmt.nrcpfcgc_cop;
            vr_nmcli_cre    := rw_craplmt.nmcooper_cop;
            
          END IF;
          
          -- Verificar se a opcao eh para listar apenas as duplicidades
          IF pr_dsdopcao = 'OI' THEN
            -- Para a duplicidade temos validar outros campos
            -- Indice das linhas que foram processadas
            vr_index_proc:= 'AIMARO'                         || -- Identificacao AYLLOS
                            TO_CHAR(rw_craplmt.cddbanco_cop) ||
                            TO_CHAR(rw_craplmt.cdagenci_cop) ||
                            TO_CHAR(rw_craplmt.nrdconta_cop) ||
                            TO_CHAR(rw_craplmt.nrcpfcgc_cop) ||
                            TO_CHAR(rw_craplmt.cddbanco_if) ||
                            TO_CHAR(rw_craplmt.cdagenci_if) ||
                            TO_CHAR(rw_craplmt.nrdconta_if) ||
                            TO_CHAR(rw_craplmt.nrcpfcgc_if) ||
                            TO_CHAR(rw_craplmt.vldocmto * 100);

            -- Verifica Duplicidade do arquivo
            vr_dsduplic:= 'N';
            IF vr_tbprocessados.EXISTS(vr_index_proc) THEN
              vr_dsduplic:= 'S';
            ELSE
              -- Armazena a linha processada
              -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
              vr_tbprocessados(vr_index_proc).nrdlinha := pr_tbcritic.COUNT() + 1;
              vr_tbprocessados(vr_index_proc).dsduplic := 'N';
              vr_tbprocessados(vr_index_proc).cddotipo := rw_craplmt.nmevento;
              vr_tbprocessados(vr_index_proc).nrcontro := rw_craplmt.nrctrlif;
              vr_tbprocessados(vr_index_proc).nrctrlif := '';
              vr_tbprocessados(vr_index_proc).vlconcil := rw_craplmt.vldocmto;
              vr_tbprocessados(vr_index_proc).dsorigem := rw_craplmt.origem;
              vr_tbprocessados(vr_index_proc).dtmensag := to_char(rw_craplmt.dttransa,'DD/MM/RRRR');
              vr_tbprocessados(vr_index_proc).dsdahora := TO_CHAR(TO_DATE(rw_craplmt.hrtransa,'SSSSS'),'HH24:MI:SS');
              vr_tbprocessados(vr_index_proc).dsespeci := 'NAO';
                
              -- Dados Conta Debitada
              vr_tbprocessados(vr_index_proc).cddbanco_deb := vr_banco_deb;
              vr_tbprocessados(vr_index_proc).cdagenci_deb := vr_cdagenci_deb;
              vr_tbprocessados(vr_index_proc).nrdconta_deb := vr_nrdconta_deb;
              vr_tbprocessados(vr_index_proc).nrcpfcgc_deb := vr_nrcpfcgc_deb;
              vr_tbprocessados(vr_index_proc).nmcooper_deb := vr_nmcli_deb;
              -- Dados Conta Creditada
              vr_tbprocessados(vr_index_proc).cddbanco_cre := vr_banco_cre;
              vr_tbprocessados(vr_index_proc).cdagenci_cre := vr_cdagenci_cre;
              vr_tbprocessados(vr_index_proc).nrdconta_cre := vr_nrdconta_cre;
              vr_tbprocessados(vr_index_proc).nrcpfcgc_cre := vr_nrcpfcgc_cre;
              vr_tbprocessados(vr_index_proc).nmcooper_cre := vr_nmcli_cre; 
              -- Origem do Erro
              vr_tbprocessados(vr_index_proc).dsorigemerro := 'AIMARO';
            END IF;
              
            -- Zerar os identificadores de criação do  erro
            vr_cria_critica:= 0; --> Identifica a geração da Crítica
            -- verificar se eh duplicado
            IF vr_dsduplic = 'S' THEN
              vr_cria_critica:= 1;
              -- verificar o registro jah foi adicionado as criticas
              IF vr_tbprocessados(vr_index_proc).dsduplic != 'S' THEN
                -- Se nao existir 
                -- Atualiza o duplicado
                vr_tbprocessados(vr_index_proc).dsduplic := 'S';
                -- Se estiver com critica apenas armazena o original
                vr_chave_conciliar:= vr_index_proc || to_char(pr_tbcritic.COUNT() + 1);
                pr_tbcritic(vr_chave_conciliar) := vr_tbprocessados(vr_index_proc);
              END IF;
              -- gerar a chave para gerar o duplicado
              vr_chave_conciliar:= vr_index_proc || to_char(pr_tbcritic.COUNT() + 1);
              -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
              pr_tbcritic(vr_chave_conciliar).nrdlinha := pr_tbcritic.COUNT() + 1;
              pr_tbcritic(vr_chave_conciliar).dsduplic := 'N';
              pr_tbcritic(vr_chave_conciliar).cddotipo := rw_craplmt.nmevento;
              pr_tbcritic(vr_chave_conciliar).nrcontro := rw_craplmt.nrctrlif;
              pr_tbcritic(vr_chave_conciliar).nrctrlif := '';
              pr_tbcritic(vr_chave_conciliar).vlconcil := rw_craplmt.vldocmto;
              pr_tbcritic(vr_chave_conciliar).dsorigem := rw_craplmt.origem;
              pr_tbcritic(vr_chave_conciliar).dtmensag := to_char(rw_craplmt.dttransa,'DD/MM/RRRR');
              pr_tbcritic(vr_chave_conciliar).dsdahora := TO_CHAR(TO_DATE(rw_craplmt.hrtransa,'SSSSS'),'HH24:MI:SS');
              pr_tbcritic(vr_chave_conciliar).dsespeci := 'NAO';
                
              -- Dados Conta Debitada
              pr_tbcritic(vr_chave_conciliar).cddbanco_deb := vr_banco_deb;
              pr_tbcritic(vr_chave_conciliar).cdagenci_deb := vr_cdagenci_deb;
              pr_tbcritic(vr_chave_conciliar).nrdconta_deb := vr_nrdconta_deb;
              pr_tbcritic(vr_chave_conciliar).nrcpfcgc_deb := vr_nrcpfcgc_deb;
              pr_tbcritic(vr_chave_conciliar).nmcooper_deb := vr_nmcli_deb;
              -- Dados Conta Creditada
              pr_tbcritic(vr_chave_conciliar).cddbanco_cre := vr_banco_cre;
              pr_tbcritic(vr_chave_conciliar).cdagenci_cre := vr_cdagenci_cre;
              pr_tbcritic(vr_chave_conciliar).nrdconta_cre := vr_nrdconta_cre;
              pr_tbcritic(vr_chave_conciliar).nrcpfcgc_cre := vr_nrcpfcgc_cre;
              pr_tbcritic(vr_chave_conciliar).nmcooper_cre := vr_nmcli_cre; 
              -- Origem do Erro
              pr_tbcritic(vr_chave_conciliar).dsorigemerro := 'AIMARO';
              
            END IF; -- FIM gerar critica duplicidade
          ELSE
            -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
            vr_tbayllos(vr_chave_conciliar).nrdlinha := vr_tbayllos.COUNT() + 1;
            vr_tbayllos(vr_chave_conciliar).dsduplic := 'N';
            vr_tbayllos(vr_chave_conciliar).cddotipo := rw_craplmt.nmevento;
            vr_tbayllos(vr_chave_conciliar).nrcontro := rw_craplmt.nrctrlif;
            vr_tbayllos(vr_chave_conciliar).nrctrlif := '';
            vr_tbayllos(vr_chave_conciliar).vlconcil := rw_craplmt.vldocmto;
            vr_tbayllos(vr_chave_conciliar).dsorigem := rw_craplmt.origem;
            vr_tbayllos(vr_chave_conciliar).dtmensag := to_char(rw_craplmt.dttransa,'DD/MM/RRRR');
            vr_tbayllos(vr_chave_conciliar).dsdahora := TO_CHAR(TO_DATE(rw_craplmt.hrtransa,'SSSSS'),'HH24:MI:SS');
            vr_tbayllos(vr_chave_conciliar).dsespeci := 'NAO';
              
            -- Dados Conta Debitada
            vr_tbayllos(vr_chave_conciliar).cddbanco_deb := vr_banco_deb;
            vr_tbayllos(vr_chave_conciliar).cdagenci_deb := vr_cdagenci_deb;
            vr_tbayllos(vr_chave_conciliar).nrdconta_deb := vr_nrdconta_deb;
            vr_tbayllos(vr_chave_conciliar).nrcpfcgc_deb := vr_nrcpfcgc_deb;
            vr_tbayllos(vr_chave_conciliar).nmcooper_deb := vr_nmcli_deb;
            -- Dados Conta Creditada
            vr_tbayllos(vr_chave_conciliar).cddbanco_cre := vr_banco_cre;
            vr_tbayllos(vr_chave_conciliar).cdagenci_cre := vr_cdagenci_cre;
            vr_tbayllos(vr_chave_conciliar).nrdconta_cre := vr_nrdconta_cre;
            vr_tbayllos(vr_chave_conciliar).nrcpfcgc_cre := vr_nrcpfcgc_cre;
            vr_tbayllos(vr_chave_conciliar).nmcooper_cre := vr_nmcli_cre; 
            -- Origem do Erro
            vr_tbayllos(vr_chave_conciliar).dsorigemerro := 'AIMARO';
          END IF; -- FIM opcao de duplicidade
        END LOOP;
        
        -- Carregar todos os registros de SPB para a data -> VR BOLETO
        FOR rw_gnmvspb IN cr_gnmvspb(pr_dtmensag => vr_dtmensag) LOOP
          vr_banco_deb:= 0;
          vr_banco_cre:= 0;
          -- VR BOLETO enviado
          IF rw_gnmvspb.dsmensag IN ('STR0026','PAG0122') THEN
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            -- Quando VR BOLETO, validar apenas se existe o registro na gnmvspb
            vr_chave_conciliar:= TO_CHAR(rw_gnmvspb.nrcnpjdb) || '_' || 
                                 TO_CHAR(rw_gnmvspb.nrcnpjcr) || '_' || 
                                 TO_CHAR(rw_gnmvspb.dsmensag) || '_' ||
                                 TO_CHAR(rw_gnmvspb.dtmensag,'DDMMRRRR') || '_' ||
                                 TO_CHAR(rw_gnmvspb.vllanmto * 100);

          -- VR BOLETO recebido
          ELSIF rw_gnmvspb.dsmensag IN ('STR0026R2','PAG0122R2') THEN
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            -- Quando VR BOLETO, validar apenas se existe o registro na gnmvspb
            vr_chave_conciliar:= TO_CHAR(rw_gnmvspb.nrcnpjcr) || '_' || 
                                 TO_CHAR(rw_gnmvspb.nrcnpjdb) || '_' || 
                                 TO_CHAR(rw_gnmvspb.dsmensag) || '_' ||
                                 TO_CHAR(rw_gnmvspb.dtmensag,'DDMMRRRR') || '_' ||
                                 TO_CHAR(rw_gnmvspb.vllanmto * 100);

          -- TED por esta finalidade não credita automaticamente a conta corrente. 
          -- Validar os campos: Agência, Conta Corrente, Valor
          ELSIF rw_gnmvspb.dsmensag IN ('STR0006') THEN
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            vr_chave_conciliar:= rw_gnmvspb.dsmensag || '_' ||
                                 TO_CHAR(TRIM(rw_gnmvspb.cdagendb)) || '_' || 
                                 TO_CHAR(TRIM(rw_gnmvspb.dscntadb)) || '_' ||
                                 TO_CHAR(rw_gnmvspb.vllanmto * 100);
              
          -- TED por esta finalidade não credita automaticamente a conta corrente. 
          -- Validar os campos: Agência, Conta Corrente, Valor
          ELSIF rw_gnmvspb.dsmensag IN('STR0006R2','PAG0142R2','STR0034R2','PAG0134R2') THEN 
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            vr_chave_conciliar:= rw_gnmvspb.dsmensag || '_' ||
                                 TO_CHAR(TRIM(rw_gnmvspb.cdagencr)) || '_' || 
                                 TO_CHAR(TRIM(rw_gnmvspb.dscntacr)) || '_' ||
                                 TO_CHAR(rw_gnmvspb.vllanmto * 100);
              
          -- Mensagem é enviada através da Cabine JD.
          -- Validar os campos: Agência, Conta Corrente, Valor
          ELSIF rw_gnmvspb.dsmensag IN ('STR0025','PAG0121') THEN
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            vr_chave_conciliar:= rw_gnmvspb.dsmensag || '_' ||
                                 TO_CHAR(TRIM(rw_gnmvspb.cdagendb)) || '_' || 
                                 TO_CHAR(TRIM(rw_gnmvspb.dscntadb)) || '_' ||
                                 TO_CHAR(rw_gnmvspb.vllanmto * 100);
              
          END IF;

          -- Buscar o codigo do Banco Creditado
          IF vr_tbbanco_ispb.exists(rw_gnmvspb.dsinstcr) THEN
            vr_banco_cre:= vr_tbbanco_ispb(rw_gnmvspb.dsinstcr);
          END IF;
          -- Conta Creditada
          vr_ispbif_cre   := rw_gnmvspb.dsinstcr;
          vr_nmcli_cre    := rw_gnmvspb.nmcliecr;
          vr_nrcpfcgc_cre := rw_gnmvspb.nrcnpjcr;
          vr_nrdconta_cre := rw_gnmvspb.dscntacr;
          vr_cdagenci_cre := rw_gnmvspb.cdagencr;

          -- Buscar o codigo do Banco Debitado
          IF vr_tbbanco_ispb.exists(rw_gnmvspb.dsinstdb) THEN
            vr_banco_deb:= vr_tbbanco_ispb(rw_gnmvspb.dsinstdb);
          END IF;
          -- Conta Debitada
          vr_ispbif_deb   := rw_gnmvspb.dsinstdb;
          vr_nmcli_deb    := rw_gnmvspb.nmcliedb;
          vr_nrcpfcgc_deb := rw_gnmvspb.nrcnpjdb;
          vr_nrdconta_deb := rw_gnmvspb.dscntadb;
          vr_cdagenci_deb := rw_gnmvspb.cdagendb;

          -- Verificar se a opcao eh para listar apenas as duplicidades
          IF pr_dsdopcao = 'OI' THEN
            
            -- Para a duplicidade temos validar outros campos
            -- Indice das linhas que foram processadas
            vr_index_proc:= 'AIMARO'                 || -- Identificacao AYLLOS
                            TO_CHAR(vr_ispbif_deb)   || -- Banco Debitada
                            TO_CHAR(vr_cdagenci_deb) || -- Agencia Debitada
                            TO_CHAR(vr_nrdconta_deb) || -- Conta Debitada
                            TO_CHAR(vr_nrcpfcgc_deb) || -- CPF/CNPJ Debitado
                            TO_CHAR(vr_ispbif_cre)   || -- Banco Creditado
                            TO_CHAR(vr_cdagenci_cre) || -- Agencia Creditada 
                            TO_CHAR(vr_nrdconta_cre) || -- Conta Creditada
                            TO_CHAR(vr_nrcpfcgc_cre) || -- CPF/CNPJ Creditado
                            TO_CHAR(rw_gnmvspb.vllanmto * 100); -- Valor (MULTIPLICAR POR 100 PARA TIRAR DECIMAIS)
                             
            -- Verifica Duplicidade do arquivo
            vr_dsduplic:= 'N';
            IF vr_tbprocessados.EXISTS(vr_index_proc) THEN
              vr_dsduplic:= 'S';
            ELSE
              -- Armazena a linha processada
              -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
              vr_tbprocessados(vr_index_proc).nrdlinha := pr_tbcritic.COUNT() + 1;
              vr_tbprocessados(vr_index_proc).dsduplic := 'N';
              vr_tbprocessados(vr_index_proc).cddotipo := rw_gnmvspb.dsmensag;
              vr_tbprocessados(vr_index_proc).nrcontro := '';
              vr_tbprocessados(vr_index_proc).nrctrlif := '';
              vr_tbprocessados(vr_index_proc).vlconcil := rw_gnmvspb.vllanmto;
              vr_tbprocessados(vr_index_proc).dtmensag := to_char(rw_gnmvspb.dtmensag,'DD/MM/RRRR');
              vr_tbprocessados(vr_index_proc).dsdahora := '00:00:00';
              vr_tbprocessados(vr_index_proc).dsespeci := 'NAO';
              -- Dados Conta Debitada
              vr_tbprocessados(vr_index_proc).cddbanco_deb := vr_banco_deb;
              vr_tbprocessados(vr_index_proc).cdagenci_deb := vr_cdagenci_deb;
              vr_tbprocessados(vr_index_proc).nrdconta_deb := vr_nrdconta_deb;
              vr_tbprocessados(vr_index_proc).nrcpfcgc_deb := vr_nrcpfcgc_deb;
              vr_tbprocessados(vr_index_proc).nmcooper_deb := vr_nmcli_deb;
              -- Dados Conta Creditada
              vr_tbprocessados(vr_index_proc).cddbanco_cre := vr_banco_cre;
              vr_tbprocessados(vr_index_proc).cdagenci_cre := vr_cdagenci_cre;
              vr_tbprocessados(vr_index_proc).nrdconta_cre := vr_nrdconta_cre;
              vr_tbprocessados(vr_index_proc).nrcpfcgc_cre := vr_nrcpfcgc_cre;
              vr_tbprocessados(vr_index_proc).nmcooper_cre := vr_nmcli_cre; 
              vr_tbprocessados(vr_index_proc).dsorigemerro := 'AIMARO';
            END IF;
              
            -- Zerar os identificadores de criação do  erro
            vr_cria_critica:= 0; --> Identifica a geração da Crítica
            -- verificar se eh duplicado
            IF vr_dsduplic = 'S' THEN
              vr_cria_critica:= 1;
              -- verificar o registro jah foi adicionado as criticas
              IF vr_tbprocessados(vr_index_proc).dsduplic != 'S' THEN
                -- Se nao existir 
                -- Atualiza o duplicado
                vr_tbprocessados(vr_index_proc).dsduplic := 'S';
                -- Se estiver com critica apenas armazena o original
                vr_chave_conciliar:= vr_index_proc || to_char(pr_tbcritic.COUNT() + 1);
                pr_tbcritic(vr_chave_conciliar) := vr_tbprocessados(vr_index_proc);
              END IF;
              -- gerar a chave para gerar o duplicado
              vr_chave_conciliar:= vr_index_proc || to_char(pr_tbcritic.COUNT() + 1);
              -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
              -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
              pr_tbcritic(vr_chave_conciliar).nrdlinha := pr_tbcritic.COUNT() + 1;
              pr_tbcritic(vr_chave_conciliar).dsduplic := 'N';
              pr_tbcritic(vr_chave_conciliar).cddotipo := rw_gnmvspb.dsmensag;
              pr_tbcritic(vr_chave_conciliar).nrcontro := '';
              pr_tbcritic(vr_chave_conciliar).nrctrlif := '';
              pr_tbcritic(vr_chave_conciliar).vlconcil := rw_gnmvspb.vllanmto;
              pr_tbcritic(vr_chave_conciliar).dtmensag := to_char(rw_gnmvspb.dtmensag,'DD/MM/RRRR');
              pr_tbcritic(vr_chave_conciliar).dsdahora := '00:00:00';
              pr_tbcritic(vr_chave_conciliar).dsespeci := 'NAO';
              -- Dados Conta Debitada
              pr_tbcritic(vr_chave_conciliar).cddbanco_deb := vr_banco_deb;
              pr_tbcritic(vr_chave_conciliar).cdagenci_deb := vr_cdagenci_deb;
              pr_tbcritic(vr_chave_conciliar).nrdconta_deb := vr_nrdconta_deb;
              pr_tbcritic(vr_chave_conciliar).nrcpfcgc_deb := vr_nrcpfcgc_deb;
              pr_tbcritic(vr_chave_conciliar).nmcooper_deb := vr_nmcli_deb;
              -- Dados Conta Creditada
              pr_tbcritic(vr_chave_conciliar).cddbanco_cre := vr_banco_cre;
              pr_tbcritic(vr_chave_conciliar).cdagenci_cre := vr_cdagenci_cre;
              pr_tbcritic(vr_chave_conciliar).nrdconta_cre := vr_nrdconta_cre;
              pr_tbcritic(vr_chave_conciliar).nrcpfcgc_cre := vr_nrcpfcgc_cre;
              pr_tbcritic(vr_chave_conciliar).nmcooper_cre := vr_nmcli_cre; 
              pr_tbcritic(vr_chave_conciliar).dsorigemerro := 'AIMARO';
              
            END IF; -- FIM gerar critica duplicidade
          ELSE
            -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
            vr_tbayllos(vr_chave_conciliar).nrdlinha := vr_tbayllos.COUNT() + 1;
            vr_tbayllos(vr_chave_conciliar).dsduplic := 'N';
            vr_tbayllos(vr_chave_conciliar).cddotipo := rw_gnmvspb.dsmensag;
            vr_tbayllos(vr_chave_conciliar).nrcontro := '';
            vr_tbayllos(vr_chave_conciliar).nrctrlif := '';
            vr_tbayllos(vr_chave_conciliar).vlconcil := rw_gnmvspb.vllanmto;
            vr_tbayllos(vr_chave_conciliar).dtmensag := to_char(rw_gnmvspb.dtmensag,'DD/MM/RRRR');
            vr_tbayllos(vr_chave_conciliar).dsdahora := '00:00:00';
            vr_tbayllos(vr_chave_conciliar).dsespeci := 'NAO';
            -- Dados Conta Debitada
            vr_tbayllos(vr_chave_conciliar).cddbanco_deb := vr_banco_deb;
            vr_tbayllos(vr_chave_conciliar).cdagenci_deb := vr_cdagenci_deb;
            vr_tbayllos(vr_chave_conciliar).nrdconta_deb := vr_nrdconta_deb;
            vr_tbayllos(vr_chave_conciliar).nrcpfcgc_deb := vr_nrcpfcgc_deb;
            vr_tbayllos(vr_chave_conciliar).nmcooper_deb := vr_nmcli_deb;
            -- Dados Conta Creditada
            vr_tbayllos(vr_chave_conciliar).cddbanco_cre := vr_banco_cre;
            vr_tbayllos(vr_chave_conciliar).cdagenci_cre := vr_cdagenci_cre;
            vr_tbayllos(vr_chave_conciliar).nrdconta_cre := vr_nrdconta_cre;
            vr_tbayllos(vr_chave_conciliar).nrcpfcgc_cre := vr_nrcpfcgc_cre;
            vr_tbayllos(vr_chave_conciliar).nmcooper_cre := vr_nmcli_cre; 
            vr_tbayllos(vr_chave_conciliar).dsorigemerro := 'AIMARO';

          END IF; -- Fim da duplicidade
                                          
        END LOOP;
        
        -- Carregar todas as mensagens devolvidas
        FOR rw_msg_devolvida IN cr_msg_devolvida (pr_dttransa => vr_dtmensag) LOOP
          -- Montar a chave de acordo com os campos que sao comparados para conciliar
          vr_chave_conciliar:= TO_CHAR(rw_msg_devolvida.nmevento) || '_' || 
                               TO_CHAR(rw_msg_devolvida.nrctrlif) || '_' || 
                               TO_CHAR(rw_msg_devolvida.vldocmto * 100);

          -- Buscar o codigo do Banco Creditado
          vr_banco_cre    := rw_msg_devolvida.cdbanco_destino;
          -- Conta Creditada
          vr_ispbif_cre   := '5463212'; -- ISPB da CECRED
          vr_nmcli_cre    := rw_msg_devolvida.nmtitular_origem;
          vr_nrcpfcgc_cre := rw_msg_devolvida.nrcpf_origem;
          vr_nrdconta_cre := rw_msg_devolvida.nrdconta;
          vr_cdagenci_cre := rw_msg_devolvida.cdagencia_origem;
          
          -- Buscar o codigo do Banco Debitado
          vr_banco_deb    := rw_msg_devolvida.cdbanco_origem;
          -- Conta Debitada
          vr_ispbif_deb   := rw_msg_devolvida.nrispbif;
          vr_nmcli_deb    := rw_msg_devolvida.nmtitular_destino;
          vr_nrcpfcgc_deb := rw_msg_devolvida.nrcpf_destino;
          vr_nrdconta_deb := rw_msg_devolvida.nrconta_destino;
          vr_cdagenci_deb := rw_msg_devolvida.cdagencia_destino;

          -- Verificar se a opcao eh para listar apenas as duplicidades
          IF pr_dsdopcao = 'OI' THEN
            
            -- Para a duplicidade temos validar outros campos
            -- Indice das linhas que foram processadas
            vr_index_proc:= 'AIMARO'                 || -- Identificacao AYLLOS
                            TO_CHAR(vr_ispbif_deb)   || -- Banco Debitada
                            TO_CHAR(vr_cdagenci_deb) || -- Agencia Debitada
                            TO_CHAR(vr_nrdconta_deb) || -- Conta Debitada
                            TO_CHAR(vr_nrcpfcgc_deb) || -- CPF/CNPJ Debitado
                            TO_CHAR(vr_ispbif_cre)   || -- Banco Creditado
                            TO_CHAR(vr_cdagenci_cre) || -- Agencia Creditada 
                            TO_CHAR(vr_nrdconta_cre) || -- Conta Creditada
                            TO_CHAR(vr_nrcpfcgc_cre) || -- CPF/CNPJ Creditado
                            TO_CHAR(rw_msg_devolvida.vldocmto * 100); -- Valor (MULTIPLICAR POR 100 PARA TIRAR DECIMAIS)
                             
            -- Verifica Duplicidade do arquivo
            vr_dsduplic:= 'N';
            IF vr_tbprocessados.EXISTS(vr_index_proc) THEN
              vr_dsduplic:= 'S';
            ELSE
              -- Armazena a linha processada
              -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
              vr_tbprocessados(vr_index_proc).nrdlinha := pr_tbcritic.COUNT() + 1;
              vr_tbprocessados(vr_index_proc).dsduplic := 'N';
              vr_tbprocessados(vr_index_proc).cddotipo := rw_msg_devolvida.nmevento;
              vr_tbprocessados(vr_index_proc).nrcontro := '';
              vr_tbprocessados(vr_index_proc).nrctrlif := rw_msg_devolvida.nrctrlif;
              vr_tbprocessados(vr_index_proc).vlconcil := rw_msg_devolvida.vldocmto;
              vr_tbprocessados(vr_index_proc).dtmensag := to_char(rw_msg_devolvida.dttransa,'DD/MM/RRRR');
              vr_tbprocessados(vr_index_proc).dsdahora := '00:00:00';
              vr_tbprocessados(vr_index_proc).dsespeci := 'NAO';
              -- Dados Conta Debitada
              vr_tbprocessados(vr_index_proc).cddbanco_deb := vr_banco_deb;
              vr_tbprocessados(vr_index_proc).cdagenci_deb := vr_cdagenci_deb;
              vr_tbprocessados(vr_index_proc).nrdconta_deb := vr_nrdconta_deb;
              vr_tbprocessados(vr_index_proc).nrcpfcgc_deb := vr_nrcpfcgc_deb;
              vr_tbprocessados(vr_index_proc).nmcooper_deb := vr_nmcli_deb;
              -- Dados Conta Creditada
              vr_tbprocessados(vr_index_proc).cddbanco_cre := vr_banco_cre;
              vr_tbprocessados(vr_index_proc).cdagenci_cre := vr_cdagenci_cre;
              vr_tbprocessados(vr_index_proc).nrdconta_cre := vr_nrdconta_cre;
              vr_tbprocessados(vr_index_proc).nrcpfcgc_cre := vr_nrcpfcgc_cre;
              vr_tbprocessados(vr_index_proc).nmcooper_cre := vr_nmcli_cre; 
              vr_tbprocessados(vr_index_proc).dsorigemerro := 'AIMARO';
            END IF;
              
            -- Zerar os identificadores de criação do  erro
            vr_cria_critica:= 0; --> Identifica a geração da Crítica
            -- verificar se eh duplicado
            IF vr_dsduplic = 'S' THEN
              vr_cria_critica:= 1;
              -- verificar o registro jah foi adicionado as criticas
              IF vr_tbprocessados(vr_index_proc).dsduplic != 'S' THEN
                -- Se nao existir 
                -- Atualiza o duplicado
                vr_tbprocessados(vr_index_proc).dsduplic := 'S';
                -- Se estiver com critica apenas armazena o original
                vr_chave_conciliar:= vr_index_proc || to_char(pr_tbcritic.COUNT() + 1);
                pr_tbcritic(vr_chave_conciliar) := vr_tbprocessados(vr_index_proc);
              END IF;
              -- gerar a chave para gerar o duplicado
              vr_chave_conciliar:= vr_index_proc || to_char(pr_tbcritic.COUNT() + 1);
              -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
              -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
              pr_tbcritic(vr_chave_conciliar).nrdlinha := pr_tbcritic.COUNT() + 1;
              pr_tbcritic(vr_chave_conciliar).dsduplic := 'N';
              pr_tbcritic(vr_chave_conciliar).cddotipo := rw_msg_devolvida.nmevento;
              pr_tbcritic(vr_chave_conciliar).nrcontro := '';
              pr_tbcritic(vr_chave_conciliar).nrctrlif := rw_msg_devolvida.nrctrlif;
              pr_tbcritic(vr_chave_conciliar).vlconcil := rw_msg_devolvida.vldocmto;
              pr_tbcritic(vr_chave_conciliar).dtmensag := to_char(rw_msg_devolvida.dttransa,'DD/MM/RRRR');
              pr_tbcritic(vr_chave_conciliar).dsdahora := '00:00:00';
              pr_tbcritic(vr_chave_conciliar).dsespeci := 'NAO';
              -- Dados Conta Debitada
              pr_tbcritic(vr_chave_conciliar).cddbanco_deb := vr_banco_deb;
              pr_tbcritic(vr_chave_conciliar).cdagenci_deb := vr_cdagenci_deb;
              pr_tbcritic(vr_chave_conciliar).nrdconta_deb := vr_nrdconta_deb;
              pr_tbcritic(vr_chave_conciliar).nrcpfcgc_deb := vr_nrcpfcgc_deb;
              pr_tbcritic(vr_chave_conciliar).nmcooper_deb := vr_nmcli_deb;
              -- Dados Conta Creditada
              pr_tbcritic(vr_chave_conciliar).cddbanco_cre := vr_banco_cre;
              pr_tbcritic(vr_chave_conciliar).cdagenci_cre := vr_cdagenci_cre;
              pr_tbcritic(vr_chave_conciliar).nrdconta_cre := vr_nrdconta_cre;
              pr_tbcritic(vr_chave_conciliar).nrcpfcgc_cre := vr_nrcpfcgc_cre;
              pr_tbcritic(vr_chave_conciliar).nmcooper_cre := vr_nmcli_cre; 
              pr_tbcritic(vr_chave_conciliar).dsorigemerro := 'AIMARO';
              
            END IF; -- FIM gerar critica duplicidade
          ELSE
            -- Gerar as informacoes de conciliacao do arquivo com os valores identificados em um dos tipos...
            vr_tbayllos(vr_chave_conciliar).nrdlinha := vr_tbayllos.COUNT() + 1;
            vr_tbayllos(vr_chave_conciliar).dsduplic := 'N';
            vr_tbayllos(vr_chave_conciliar).cddotipo := rw_msg_devolvida.nmevento;
            vr_tbayllos(vr_chave_conciliar).nrcontro := '';
            vr_tbayllos(vr_chave_conciliar).nrctrlif := rw_msg_devolvida.nrctrlif;
            vr_tbayllos(vr_chave_conciliar).vlconcil := rw_msg_devolvida.vldocmto;
            vr_tbayllos(vr_chave_conciliar).dtmensag := to_char(rw_msg_devolvida.dttransa,'DD/MM/RRRR');
            vr_tbayllos(vr_chave_conciliar).dsdahora := '00:00:00';
            vr_tbayllos(vr_chave_conciliar).dsespeci := 'NAO';
            -- Dados Conta Debitada
            vr_tbayllos(vr_chave_conciliar).cddbanco_deb := vr_banco_deb;
            vr_tbayllos(vr_chave_conciliar).cdagenci_deb := vr_cdagenci_deb;
            vr_tbayllos(vr_chave_conciliar).nrdconta_deb := vr_nrdconta_deb;
            vr_tbayllos(vr_chave_conciliar).nrcpfcgc_deb := vr_nrcpfcgc_deb;
            vr_tbayllos(vr_chave_conciliar).nmcooper_deb := vr_nmcli_deb;
            -- Dados Conta Creditada
            vr_tbayllos(vr_chave_conciliar).cddbanco_cre := vr_banco_cre;
            vr_tbayllos(vr_chave_conciliar).cdagenci_cre := vr_cdagenci_cre;
            vr_tbayllos(vr_chave_conciliar).nrdconta_cre := vr_nrdconta_cre;
            vr_tbayllos(vr_chave_conciliar).nrcpfcgc_cre := vr_nrcpfcgc_cre;
            vr_tbayllos(vr_chave_conciliar).nmcooper_cre := vr_nmcli_cre; 
            vr_tbayllos(vr_chave_conciliar).dsorigemerro := 'AIMARO';

          END IF; -- Fim da duplicidade
                                          
        END LOOP;
        
        -- Busca a proxima data
        vr_index_data := vr_tbdatas.NEXT(vr_index_data);
      END LOOP;
      
      -- Verificar se a opcao eh para listar apenas as duplicidades
      IF pr_dsdopcao != 'OI' THEN
        -- A CONCILIACAO SOMENTE ACONTECE SE A OPCAO NAO EH PARA DUPLICIDADES
    
        -------------------- INICIO DA CONCILIACAO DO ARQUIVO COM O AYLLOS --------------------
        -- Buscar a primeira chave de conciliacao do ARQUIVO
        vr_chave_conciliar := vr_tbarquivo.FIRST;
        -- Enquanto existir data, continua o processo
        WHILE vr_chave_conciliar IS NOT NULL LOOP
          -- Verifica se nao existe o lancamento no AYLLOS
          IF NOT vr_tbayllos.EXISTS(vr_chave_conciliar) THEN
            -- Verificar se o erro ja foi carregado
            IF pr_tbcritic.EXISTS(vr_chave_conciliar) THEN
              -- Duplicado 
              pr_tbcritic(vr_chave_conciliar).dsduplic:= 'S';
            ELSE 
              -- Se nao existir no ayllos, gera a critica
              pr_tbcritic(vr_chave_conciliar) := vr_tbarquivo(vr_chave_conciliar);
            END IF;
          END IF;
          
          vr_chave_conciliar := vr_tbarquivo.NEXT(vr_chave_conciliar);
        END LOOP;
      
        -------------------- INICIO DA CONCILIACAO DO AYLLOS COM O ARQUIVO --------------------
        -- Buscar a primeira chave de conciliacao do AYLLOS
        vr_chave_conciliar := vr_tbayllos.FIRST;
        -- Enquanto existir data, continua o processo
        WHILE vr_chave_conciliar IS NOT NULL LOOP
          -- Verifica se nao existe o lancamento no ARQUIVO
          IF NOT vr_tbarquivo.EXISTS(vr_chave_conciliar) THEN
            -- Verificar se o erro ja foi carregado
            IF pr_tbcritic.EXISTS(vr_chave_conciliar) THEN
              -- Duplicado 
              pr_tbcritic(vr_chave_conciliar).dsduplic:= 'S';
            ELSE 
              -- Se nao existir no ayllos, gera a critica
              pr_tbcritic(vr_chave_conciliar) := vr_tbayllos(vr_chave_conciliar);
            END IF;
          END IF;
          
          vr_chave_conciliar := vr_tbayllos.NEXT(vr_chave_conciliar);
        END LOOP;
      -- FIM da opcao de duplicidade  
      END IF;
    
      -- Limpar a tabela
      vr_tbprocessados.DELETE;
      vr_tbarquivo.DELETE;
      vr_tbayllos.DELETE;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Limpar a tabela
        vr_tbprocessados.DELETE;
        vr_tbarquivo.DELETE;
        vr_tbayllos.DELETE;
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Limpar a tabela
        vr_tbprocessados.DELETE;
        vr_tbarquivo.DELETE;
        vr_tbayllos.DELETE;
      
        IF SQLCODE < 0 THEN
          vr_dscritic:= vr_dscritic || ' ' ||
                        replace (dbms_utility.format_error_backtrace || ' - ' ||
                                 dbms_utility.format_error_stack,'"', NULL);
        END IF;
        
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro geral (SSPB0002.pc_proc_arq_jdspb_ayllos): ' || 
                       REPLACE(REPLACE(vr_dscritic,chr(10),NULL),chr(13), NULL);

    END;
  END pc_proc_arq_jdspb_ayllos;
      
  PROCEDURE pc_proc_concilia_ted_tec(pr_dspartes   IN VARCHAR2           --> Partes => PJA(JDSPB / AYLLOS)
                                    ,pr_dsdopcao   IN VARCHAR2           --> Opção => OT (Todos) / OI (Indícios de Duplicidade) 
                                    ,pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_proc_concilia_ted_tec
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 03/08/2015                        Ultima atualizacao: 01/06/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar as inconsistencias no arquivo de conciliação de TED/TEC

    Alteracoes: 01/06/2016 - Ajustes na forma de recebimento do arquivo que esta sendo 
                             conciliado e na geracao do arquivo de criticas
                             (Douglas - Chamado 443701)
    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro   EXCEPTION;
      vr_exc_inform EXCEPTION;
      
      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_dsdireto VARCHAR2(100);
      vr_nmarquiv VARCHAR2(100);

      -- Indice das criticas
      vr_ind_critic VARCHAR2(150);
      
      -- Tabelas 
      vr_tbcritic typ_tbcritica; -- Tabela de criticas encontradas na validação do arquivo
      
      -- Linha gerada no arquivo de saida
      vr_linha VARCHAR2(32000);
      -- Declarando handle do Arquivo
      vr_ind_arquivo utl_file.file_type;
      
      -- Quantidade de criticas
      vr_qtcritic INTEGER;
      
    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca o diretório do upload do arquivo
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'M'
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'spb');
                                          
      -- Nome do arquivo possui apenas o nome sem a extensão
      -- A extensão por padrão é csv
      vr_nmarquiv := pr_nmarquiv || '.csv';
                                          
      -- Verifica se o arquivo existe
      IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||vr_nmarquiv) THEN
        -- Retorno de erro
        vr_dscritic := GENE0007.fn_convert_db_web('Arquivo não encontrado. (' || 
                                                  vr_dsdireto||'/'||vr_nmarquiv || 
                                                  ')');
        pr_nmdcampo := 'nmarquiv';
        RAISE vr_exc_erro;
      END IF;
      
      -- Verificar quais são as partes 
      CASE pr_dspartes
        WHEN 'PJA' THEN /* JDPSB/AYLLOS */
          pc_proc_arq_jdspb_ayllos(pr_cdcooper => vr_cdcooper
                                  ,pr_nmdireto => vr_dsdireto
                                  ,pr_nmarquiv => vr_nmarquiv
                                  ,pr_dsdopcao => pr_dsdopcao
                                  ,pr_tbcritic => vr_tbcritic
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
        ELSE
          vr_dscritic := GENE0007.fn_convert_db_web('Parâmetro PARTES inválido');
          pr_nmdcampo := 'dspartes';
      END CASE;
      
      IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      vr_qtcritic:= 0;
      -- Verificar se foram identificadas criticas
      IF vr_tbcritic.COUNT() = 0 THEN
        RAISE vr_exc_inform;
      END IF;

      -- Apos o processamento geramos o arquivo de criticas
      -- Caminho saida do Arquivo
      vr_nmarquiv := pr_nmarquiv || '_criticas.csv';
      -- Abre arquivo em modo de escrita (W)
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto    --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                              ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquivo --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);  --> Erro  
                            
      vr_linha := 'Tipo;Numero de Controle;Numero de Controle IF;Valor;Data;Horario;Origem Erro;Origem;Especie;'|| 
	              'Banco Debitado;Agencia Debitado;Conta Debitado;CPF/CNPJ Debitado;Nome Cooperado Debitado;' ||
                  'Banco Creditado;Agencia Creditado;Conta Creditado;CPF/CNPJ Creditado;Nome Cooperado Creditado;';
      -- Escrever o Cabecalho
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha);

      vr_ind_critic:= vr_tbcritic.FIRST;
      WHILE vr_ind_critic IS NOT NULL LOOP

                    -- Detalhamento
        vr_linha := '"' || vr_tbcritic(vr_ind_critic).cddotipo || '";' || -- Tipo
                    '"' || vr_tbcritic(vr_ind_critic).nrcontro || '";' || -- Numero de Controle
                    '"' || vr_tbcritic(vr_ind_critic).nrctrlif || '";' || -- Numero de Controle IF
                    '"' || to_char(vr_tbcritic(vr_ind_critic).vlconcil,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')  || '";' || -- Valor
                    '"' || vr_tbcritic(vr_ind_critic).dtmensag || '";' || -- Data
                    '"' || vr_tbcritic(vr_ind_critic).dsdahora || '";' || -- Horario
                    -- Origem e Especie
                    '"' || vr_tbcritic(vr_ind_critic).dsorigemerro || '";' || -- Origem Erro
                    '"' || vr_tbcritic(vr_ind_critic).dsorigem || '";' || -- Origem
                    '"' || vr_tbcritic(vr_ind_critic).dsespeci || '";' || -- Especie
                    -- Conta Debitada
                    '"' || vr_tbcritic(vr_ind_critic).cddbanco_deb || '";' || -- Banco Debitado
                    '"' || vr_tbcritic(vr_ind_critic).cdagenci_deb || '";' || -- Agencia Debitada
                    '"' || vr_tbcritic(vr_ind_critic).nrdconta_deb || '";' || -- Conta Debitada
                    '"' || vr_tbcritic(vr_ind_critic).nrcpfcgc_deb || '";' || -- CPF Debitado
                    '"' || vr_tbcritic(vr_ind_critic).nmcooper_deb || '";' || -- Nome Debitado
                    -- Conta Creditada
                    '"' || vr_tbcritic(vr_ind_critic).cddbanco_cre || '";' || -- Banco Creditado
                    '"' || vr_tbcritic(vr_ind_critic).cdagenci_cre || '";' || -- Agencia Creditada
                    '"' || vr_tbcritic(vr_ind_critic).nrdconta_cre || '";' || -- Conta Creditada
                    '"' || vr_tbcritic(vr_ind_critic).nrcpfcgc_cre || '";' || -- CPF Creditado
                    '"' || vr_tbcritic(vr_ind_critic).nmcooper_cre || '";' || -- Nome Creditado
                    -- Origem Erro
                    '"' || vr_tbcritic(vr_ind_critic).dscritic || '";' ; -- Critica
                    
        GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha);
        
        vr_qtcritic := vr_qtcritic + 1;
        vr_ind_critic:= vr_tbcritic.NEXT(vr_ind_critic); -- Proximo registro
      END LOOP; -- Loop das críticas
      
      -- Fechar o arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);
      
      -- gerar a mensagem com a quantidade de criticas 
      RAISE vr_exc_inform;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
        
      WHEN vr_exc_inform THEN
        -- Retornar a quantidade de Criticas identificadas
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Inform>' || to_char(vr_qtcritic) || '</Inform></Root>');
        ROLLBACK;
        
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (SSPB0002.pc_proc_concilia_ted_tec): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_proc_concilia_ted_tec;

  /* Rotina para paginar as criticas da conciliação de TED/TEC */
  PROCEDURE pc_paginar_criticas(pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo
                               ,pr_nrinicri   IN INTEGER            --> Numero da critica Inicial
                               ,pr_nrqtdcri   IN INTEGER            --> Quantidade de Criticas para paginar
                               ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_paginar_criticas
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 02/06/2016                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para paginar as criticas da conciliação de TED/TEC

    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exceção
      vr_exc_erro    EXCEPTION;
      vr_exc_fim_qtd EXCEPTION;
      
      -- Variáveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      vr_dsdireto VARCHAR2(100);
      vr_nmarquiv VARCHAR2(100);

      -- Indice das criticas
      vr_ind_critic VARCHAR2(150);
      
      vr_nrinicri   INTEGER;
      vr_nrqtdcri   INTEGER;
      
      -- Linha gerada no arquivo de saida
      vr_linha VARCHAR2(32000);
      -- Declarando handle do Arquivo
      vr_input_file utl_file.file_type;
      
    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Busca o diretório do upload do arquivo
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'M'
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'spb');
                                          
      -- Nome do arquivo possui apenas o nome sem a extensão
      -- A extensão por padrão é csv
      vr_nmarquiv := pr_nmarquiv || '_criticas.csv';
                                          
      -- Verifica se o arquivo existe
      IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||vr_nmarquiv) THEN
        -- Retorno de erro
        vr_dscritic := GENE0007.fn_convert_db_web('Arquivo de críticas não encontrado. (' || 
                                                  vr_dsdireto||'/'||vr_nmarquiv || 
                                                  ')');
        pr_nmdcampo := 'nmarquiv';
        RAISE vr_exc_erro;
      END IF;

      -- Abrir o arquivo de criticas
      gene0001.pc_abre_arquivo (pr_nmdireto => vr_dsdireto  --> Diretório do arquivo
                               ,pr_nmarquiv => vr_nmarquiv        --> Nome do arquivo
                               ,pr_tipabert => 'R'                --> Modo de abertura (R,W,A)
                               ,pr_utlfileh => vr_input_file      --> Handle do arquivo aberto
                               ,pr_des_erro => vr_dscritic);      --> Descricao do erro

      -- Se retornou erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Recriar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><criticas></criticas></Root>');

      vr_ind_critic := 0;
      vr_nrinicri   := NVL(pr_nrinicri, 1);
      vr_nrqtdcri   := NVL(pr_nrqtdcri,50);

      BEGIN
        -- Laco para leitura de linhas do arquivo
        LOOP
          -- Carrega handle do arquivo
          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                      ,pr_des_text => vr_linha); --> Texto lido
                                      
          vr_ind_critic := vr_ind_critic + 1;
          
          -- Verificar se eh a primeira linha
          IF vr_ind_critic = 1 THEN
            -- A primeira linha eh o cabecalho e deve ser ignorado
            CONTINUE;
          END IF;
          
          -- Linha atual menor que a critica inical da paginacao
          IF vr_ind_critic < vr_nrinicri THEN
            -- Se a linha atual eh menor que a critica inicial 
            -- Ignora a linha e vai para a proxima
            CONTINUE;
          END IF;
          
          -- Linha atual maior que a critica final
          IF vr_ind_critic >= vr_nrinicri + vr_nrqtdcri THEN
            -- Se a linha atual eh maior que a critica final
            -- para o loop pois ja temos todas as criticas para paginar
            RAISE vr_exc_fim_qtd;
          END IF;

          -- Retirar quebra de linha
          vr_linha := REPLACE(REPLACE(vr_linha,CHR(10)),CHR(13));
          -- Remover aspas duplas que foram utilizados na geracao do arquivo
          vr_linha := REPLACE(vr_linha,'"','');
          
          -- Criar nodo filho
          pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/criticas'
                                            ,XMLTYPE('<critica>'
                                                   -- Detalhamento
                                                   ||'    <nrdlinha>'|| vr_ind_critic ||'</nrdlinha>'
                                                   ||'    <cddotipo>'|| gene0002.fn_busca_entrada(1,vr_linha,';') ||'</cddotipo>'
                                                   ||'    <nrcontro>'|| gene0002.fn_busca_entrada(2,vr_linha,';') ||'</nrcontro>'
                                                   ||'    <nrctrlif>'|| gene0002.fn_busca_entrada(3,vr_linha,';') ||'</nrctrlif>'
                                                   ||'    <vlconcil>'|| gene0002.fn_busca_entrada(4,vr_linha,';') ||'</vlconcil>'
                                                   ||'    <dtmensag>'|| gene0002.fn_busca_entrada(5,vr_linha,';') ||'</dtmensag>'
                                                   ||'    <dsdahora>'|| gene0002.fn_busca_entrada(6,vr_linha,';') ||'</dsdahora>'
                                                   -- Origem e Especie
                                                   ||'    <dsorigemerro>'|| gene0002.fn_busca_entrada(7,vr_linha,';') ||'</dsorigemerro>'
                                                   ||'    <dsorigem>'|| gene0002.fn_busca_entrada(8,vr_linha,';') ||'</dsorigem>'
                                                   ||'    <dsespeci>'|| gene0002.fn_busca_entrada(9,vr_linha,';') ||'</dsespeci>'
                                                   -- Conta Debitada
                                                   ||'    <cddbanco_deb>'|| gene0002.fn_busca_entrada(10,vr_linha,';') ||'</cddbanco_deb>'
                                                   ||'    <cdagenci_deb>'|| gene0002.fn_busca_entrada(11,vr_linha,';') ||'</cdagenci_deb>'
                                                   ||'    <nrdconta_deb>'|| gene0002.fn_busca_entrada(12,vr_linha,';') ||'</nrdconta_deb>'
                                                   ||'    <nrcpfcgc_deb>'|| gene0002.fn_busca_entrada(13,vr_linha,';') ||'</nrcpfcgc_deb>'
                                                   ||'    <nmcooper_deb>'|| gene0002.fn_busca_entrada(14,vr_linha,';') ||'</nmcooper_deb>'
                                                   -- Conta Creditada
                                                   ||'    <cddbanco_cre>'|| gene0002.fn_busca_entrada(15,vr_linha,';') ||'</cddbanco_cre>'
                                                   ||'    <cdagenci_cre>'|| gene0002.fn_busca_entrada(16,vr_linha,';') ||'</cdagenci_cre>'
                                                   ||'    <nrdconta_cre>'|| gene0002.fn_busca_entrada(17,vr_linha,';') ||'</nrdconta_cre>'
                                                   ||'    <nrcpfcgc_cre>'|| gene0002.fn_busca_entrada(18,vr_linha,';') ||'</nrcpfcgc_cre>'
                                                   ||'    <nmcooper_cre>'|| gene0002.fn_busca_entrada(19,vr_linha,';') ||'</nmcooper_cre>'
                                                   -- Origem da Critica
                                                   ||'    <dscritic>'|| gene0002.fn_busca_entrada(20,vr_linha,';') ||'</dscritic>'
                                                   ||'</critica>'));
        END LOOP; -- Loop Arquivo
      EXCEPTION 

        WHEN vr_exc_fim_qtd THEN
          -- Nao gerar critica, finaliza o loop de criticas que devem ser exibidas
          vr_dscritic:= NULL;
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

        WHEN no_data_found THEN
          -- Nao gerar critica, pois eh o fim do arquivo
          vr_dscritic:= NULL;
          -- Fechar o arquivo
          GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
          
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro na leitura do arquivo de criticas: ' || SQLERRM;
      END;

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (SSPB0002.pc_paginar_criticas): ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_paginar_criticas;



  PROCEDURE pc_gera_arquivo_contabil (pr_cdcritic OUT crapcri.cdcritic%TYPE
                                              ,pr_dscritic OUT VARCHAR2)  IS
  /* ..........................................................................

   Objetivo  : Gerar arquivo contabil para o Matera das informações da Ailos

   Alteracoes: 
   ........................................................................... */

  -- CURSORES
  -- Seleciona as informações das mensagens das operações enviadas
  CURSOR cr_arq_cont (pr_dtmvtolt in date) is
  Select tac.nmmensagem
        ,tac.nrcontrole_if_str_pag
        ,tac.dtlancamento_contabil
        ,tac.vlrlancamento
        ,tac.dsflexivel
        ,his.nrctadeb nrconta_deb
        ,his.nrctacrd nrconta_cred
        ,his.dsexthst ||' '||tac.dsflexivel dsrefere
        ,tac.nrcentrocusto
        ,tac.rowid
  from tbspb_arquivo_contabil tac
      ,craphis his
  where trunc(tac.dtlancamento_contabil) = trunc(pr_dtmvtolt)
  and   tac.idsituacao  = 0
  and   tac.cdhistor    = his.cdhistor
  and   his.cdcooper    = 3;     
  

  -- VARIÁVEIS
  -- Código do programa
  vr_cdprogra      VARCHAR2(10);
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%TYPE;

    
  -- Tratamento de erros
  vr_exc_saida     EXCEPTION;
  vr_dscritic VARCHAR2(4000);
  --
  vr_exc_erro EXCEPTION;  
  vr_file_erro     EXCEPTION;  
  --

-- constantes para geracao de arquivos contabeis
  vc_cdacesso CONSTANT VARCHAR2(24) := 'DIR_ARQ_CONTAB_X';
  vc_cdtodascooperativas INTEGER := 0;

  vr_con_dtmvtolt      VARCHAR2(20);
  vr_ind_arquivo       utl_file.file_type;  
  vr_contador          NUMBER := 0;  
  vr_utlfileh          VARCHAR2(200); 
  vr_nmarquiv          VARCHAR2(100);
  vr_linhadet          VARCHAR2(500);
  vr_dscomando         VARCHAR2(500);  
  vr_retfile           VARCHAR2(400);
  vr_typ_saida         VARCHAR2(4000);  
  vr_dircon            VARCHAR2(200);
  vr_arqcon            VARCHAR2(200);   
  
  -- Escrever linha no arquivo
  PROCEDURE pc_gravar_linha(pr_linha IN VARCHAR2) IS
  BEGIN
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,pr_linha);
  END pc_gravar_linha;  
  
  Function fn_valida_fase_55 (pr_nrcontrole in varchar2
                             ,pr_nmmensagem in varchar2) return boolean is
    vr_count number:= 0;
  Begin
    /* Validar somente para as mensagens enviadas que possuem o retorno 55/57. As demais não necessitam ser validadas.*/
    If pr_nmmensagem in ('STR0003','STR0004','STR0007','STR0020','SEL1069',
                         'LDL0022','RDC0002','RDC0007','SLB0002','LTR0004') Then 
       --
       Select count(*) 
       into vr_count
       From Tbspb_Msg_Enviada a
           ,Tbspb_Msg_Enviada_Fase b
       Where a.nrseq_mensagem = b.nrseq_mensagem
       and   a.nrcontrole_if = pr_nrcontrole
       and   b.cdfase in (55,57);
       
       If vr_count <> 0 Then
          Return True;
       Else
          Return False;
       End If;          
    Else
       /* Mensagem Recebida*/
       Return True;
    End If;   
  End fn_valida_fase_55;

  
  PROCEDURE pc_abre_arquivo(pr_cdcooper  IN NUMBER,
                            pr_dtmvtolt  IN DATE,
                            pr_nmarquiv  IN VARCHAR2,
                            pr_retfile  OUT VARCHAR2) IS

  BEGIN
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_gera_arquivo_contabil.pc_abre_arquivo');
         
    -- Define o diretório do arquivo
    vr_utlfileh := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'contab') ;

    -- Define Nome do Arquivo
    vr_nmarquiv := to_char(pr_dtmvtolt, 'yy') ||
                   to_char(pr_dtmvtolt, 'mm') ||
                   to_char(pr_dtmvtolt, 'dd') ||
                   '_'||pr_nmarquiv||'.TMP';
         
    pr_retfile  := to_char(pr_dtmvtolt, 'yy') ||
                   to_char(pr_dtmvtolt, 'mm') ||
                   to_char(pr_dtmvtolt, 'dd') ||
                   '_'||pr_nmarquiv||'.txt';


    -- Abre arquivo em modo de escrita (W)
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                            ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);       --> Erro
 
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao executar pc_gera_arquivo_contabil.pc_abre_arquivo. Erro:'||sqlerrm;         

      CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper
                                   ,pr_compleme => vr_dscritic );
  END pc_abre_arquivo;
    
BEGIN

  -- A data de movimento deve ser sempre a do dia anterior, caso não seja um dia
  -- util, a função Gene0005 busca o primeiro o dia util anterior ao atual
  vr_dtmvtolt := GENE0005.fn_valida_dia_util(3,trunc(SYSDATE) - 1,'A');
  --
  --vr_dtmvtolt := trunc(sysdate); /*Retirar ao final, usado para testes*/
  --
  -- Definir as datas das linhas do arquivo
  vr_con_dtmvtolt := '55' ||
                     to_char(vr_dtmvtolt, 'yy') ||
                     to_char(vr_dtmvtolt, 'mm') ||
                     to_char(vr_dtmvtolt, 'dd');

  vr_contador := 0;
    
  --Leitura dos lançamentos gravados no dia anterior (D-1)
  FOR rw_cr_arq_cont IN cr_arq_cont(vr_dtmvtolt) LOOP
      
      vr_contador := vr_contador + 1;
        
      IF vr_contador = 1 THEN
             
        pc_abre_arquivo(3,vr_dtmvtolt,'LCTOSSPB',vr_retfile);

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_file_erro;
        END IF;

      END IF;  
   
      IF fn_valida_fase_55 (rw_cr_arq_cont.nrcontrole_if_str_pag
                          , rw_cr_arq_cont.nmmensagem) THEN 
        --                  
        vr_linhadet := TRIM(vr_con_dtmvtolt) || ',' ||
                       TRIM(to_char(rw_cr_arq_cont.dtlancamento_contabil, 'ddmmyy')) || ','|| 
                       rw_cr_arq_cont.nrconta_deb||','||
                       rw_cr_arq_cont.nrconta_cred||','||                         
                       TRIM(to_char(rw_cr_arq_cont.vlrlancamento, '99999999999990.00')) ||
                       ',5210,' ||
                       '"'||rw_cr_arq_cont.dsrefere||'"';

        -- Gravar Linha
        pc_gravar_linha(vr_linhadet);
        --
        If rw_cr_arq_cont.nrcentrocusto is not null Then
           vr_linhadet := rw_cr_arq_cont.nrcentrocusto||','||TRIM(to_char(rw_cr_arq_cont.vlrlancamento, '99999999999990.00'));
           -- Gravar Linha do Centro de custo/Valor
           pc_gravar_linha(vr_linhadet);
        End If;  
        -- Atualiza status do lançamento para gerado
        Begin
          Update Tbspb_Arquivo_Contabil tac
          set tac.idsituacao = 1
          Where tac.rowid = rw_cr_arq_cont.rowid;
        End;  
      ELSE
        -- Atualiza status do lançamento para rejeitado
        Begin
          Update Tbspb_Arquivo_Contabil tac
          set tac.idsituacao = 2
          Where tac.rowid = rw_cr_arq_cont.rowid;
        End;  
      END IF;        
      --
  END LOOP;
  --
   
  IF vr_contador > 0 THEN
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

    -- Executa comando UNIX para converter arq para Dos
    vr_dscomando := 'ux2dos ' || vr_utlfileh || '/' || vr_nmarquiv || ' > '
                              || vr_utlfileh || '/' || vr_retfile || ' 2>/dev/null';

    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;

    -- Busca o diretório para contabilidade
     vr_dircon := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => vc_cdtodascooperativas
                                           ,pr_cdacesso => vc_cdacesso);
                                             
     vr_arqcon := to_char(vr_dtmvtolt, 'yy') ||
                  to_char(vr_dtmvtolt, 'mm') ||
                  to_char(vr_dtmvtolt, 'dd') ||
                  '_'||LPAD(TO_CHAR(3),2,0)||
                  '_LCTOSSPB.txt';

      -- Executa comando UNIX para converter arq para Dos
     vr_dscomando := 'ux2dos '||vr_utlfileh||'/'||vr_retfile||' > '||
                                vr_dircon||'/'||vr_arqcon||' 2>/dev/null';

    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_erro;
    END IF;

    -- Remover arquivo tmp
    vr_dscomando := 'rm ' || vr_utlfileh || '/' || vr_nmarquiv;

    -- Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);

    IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
    END IF;
    
    --
    COMMIT;
    --
  END IF;
    
EXCEPTION
  WHEN vr_exc_erro THEN
    Rollback;
    pr_dscritic := vr_dscritic;
  WHEN vr_file_erro THEN
    Rollback;
    pr_dscritic := vr_dscritic;
  WHEN OTHERS THEN
    Rollback;
    -- Monta mensagem de erro
    pr_dscritic := 'Erro em pc_gera_arquivo_contabil: ' || SQLERRM;
    CECRED.pc_internal_exception( pr_cdcooper => 3 
                                 ,pr_compleme => pr_dscritic );

END pc_gera_arquivo_contabil;

FUNCTION fn_depara_situacao_enviada (ds_sitaimaro IN VARCHAR2
                                    ,ds_sitjd     IN VARCHAR2) return boolean is

  vr_retorno boolean;
BEGIN
  IF ds_sitaimaro = 'EFETIVADA' AND ds_sitjd = '007' THEN
     vr_retorno:= True;
  ELSIF ds_sitaimaro = 'DEVOLVIDA' AND ds_sitjd = '019' THEN
     vr_retorno:= True;
  ELSIF ds_sitaimaro = 'REJEITADA' AND ds_sitjd  IN ('006','011','017') THEN
     vr_retorno:= True;   
  ELSIF ds_sitaimaro = 'PENDENTE CAMARA' AND ds_sitjd = '040' THEN
     vr_retorno:= True;     
  ELSIF ds_sitaimaro = 'EM PROCESSAMENTO' AND ds_sitjd  IN ('005','010','014','015') THEN
     vr_retorno:= True;  
  ELSIF ds_sitaimaro = 'ESTORNADA' THEN   
     vr_retorno:= False;
  ELSIF ds_sitjd IN ('003','004','008','009','012','013','016','020','021','022','023','030','032','035','036') THEN
     vr_retorno:= False;   
  ELSE
     vr_retorno:= False;  
  END IF;
  RETURN vr_retorno;
     
END fn_depara_situacao_enviada;

FUNCTION fn_depara_situacao_recebida (ds_sitaimaro IN VARCHAR2
                                     ,ds_sitjd     IN VARCHAR2) return boolean is
  vr_retorno boolean;
  
BEGIN
  IF ds_sitaimaro = 'EFETIVADA' AND ds_sitjd = '007' THEN
     vr_retorno:= True;
  ELSIF ds_sitaimaro = 'DEVOLVIDA' AND ds_sitjd = '019' THEN
     vr_retorno:= True;   
  ELSE
     vr_retorno:= False;   
  END IF;
  
  RETURN vr_retorno;
     
END fn_depara_situacao_recebida;

FUNCTION fn_depara_descricao_jd (ds_sitjd in VARCHAR2)RETURN VARCHAR2 IS
  vr_descricao_sit VARCHAR2(50);
BEGIN
  IF ds_sitjd= '003' THEN
    vr_descricao_sit:= 'Pendente IF';
  ELSIF ds_sitjd = '004' THEN
    vr_descricao_sit:= 'Pendente Bacen';
  ELSIF ds_sitjd = '005' THEN
    vr_descricao_sit:= 'Enviado Bacen';	
  ELSIF ds_sitjd = '006' THEN
    vr_descricao_sit:= 'Rejeitado Bacen';	
  ELSIF ds_sitjd = '007' THEN
    vr_descricao_sit:= 'Efetivado';	
  ELSIF ds_sitjd = '008' THEN
    vr_descricao_sit:= 'Confirmado';
  ELSIF ds_sitjd = '009' THEN
    vr_descricao_sit:= 'Cancelado';
  ELSIF ds_sitjd = '010' THEN
    vr_descricao_sit:= 'Aguardando Confirmação';	
  ELSIF ds_sitjd = '011' THEN
    vr_descricao_sit:= 'Rejeitado IF';	
  ELSIF ds_sitjd = '012' THEN
    vr_descricao_sit:= 'Aguardando Cancelamento';
  ELSIF ds_sitjd = '013' THEN
    vr_descricao_sit:= 'Aguardando Processamento';
  ELSIF ds_sitjd = '014' THEN
    vr_descricao_sit:= 'Aguardando Piloto';	
  ELSIF ds_sitjd = '015' THEN
     vr_descricao_sit:= 'Enviando CIP';	
  ELSIF ds_sitjd = '016' THEN
    vr_descricao_sit:= 'Pendente CIP';
  ELSIF ds_sitjd = '017' THEN
    vr_descricao_sit:= 'Rejeitado CIP';	
  ELSIF ds_sitjd = '019' THEN
    vr_descricao_sit:=   'Devolvido';
  ELSIF ds_sitjd = '020' THEN
     vr_descricao_sit:=  'Lançada';
  ELSIF ds_sitjd = '021' THEN
     vr_descricao_sit:=  'Liberada';
  ELSIF ds_sitjd = '022' THEN
     vr_descricao_sit:=  'Pendente de Título';
  ELSIF ds_sitjd = '023' THEN
     vr_descricao_sit:=  'Pendente de Operação';
  ELSIF ds_sitjd = '030' THEN
     vr_descricao_sit:=  'Cancelamento BC';
  ELSIF ds_sitjd = '032' THEN
     vr_descricao_sit:=  'Aguardando Horário';
  ELSIF ds_sitjd = '035' THEN
     vr_descricao_sit:=  'Devolução Pedida';
  ELSIF ds_sitjd = '036' THEN
     vr_descricao_sit:=  'Processada';
  ELSIF ds_sitjd = '040' THEN
    vr_descricao_sit:= 'Mensagem Agendada';
  ELSE
    vr_descricao_sit:= 'Nao definido - '|| ds_sitjd;  
  END IF;
  
  RETURN vr_descricao_sit;
  
END;  


PROCEDURE pc_gera_conciliacao_spb ( pr_tipo_concilacao  IN VARCHAR2 --> Tipo de execução (D - Diaria, M - Manual)
                                   ,pr_tipo_mensagem    IN VARCHAR2 --> Tipo de mensagem a conciliar (E - Enviada, R - Recebida, T - Todas)
                                   ,pr_data_ini IN VARCHAR2         --> Data de início da conciliação
                                   ,pr_data_fim IN VARCHAR2         --> Data de fim da conciliação
                                   ,pr_dsendere IN VARCHAR2         --> Endereço de email a ser enviado a notificação
                                   ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2)  IS         --> Descrição da crítica
  /* ..........................................................................

   Objetivo  : Gerar o arquivo de conciliação entre o Aimaro e JDSPB

   Alteracoes:    08/08/2019 - Melhorias para otimizar a performance de execução da conciliação.
                               Jose Dill - Mouts (P475 - Sprint E)
   ........................................................................... */
 
  /* Seleciona as informações das mensagens enviadas no Aimaro, de acordo com o período solicitado*/
  CURSOR cr_msgenvaimaro (pr_data_ini date
                         ,pr_data_fim date) IS 
  SELECT tma.nmmensagem
        ,tma.nrcontrole_if 
        ,tma.cdcooper
        ,tma.dhmensagem
        ,tma.nrseq_mensagem
        ,tma.nrdconta
        ,tma.vlmensagem
        ,tma.nrispb_deb
        ,tma.nrispb_cre
        ,to_char(cop.cdagectl) nr_legado
        ,null dataincage
        ,1 Agendado
  FROM tbspb_msg_enviada tma
      ,crapcop cop
  WHERE TRUNC(tma.dhmensagem) BETWEEN pr_data_ini
                           AND pr_data_fim
  AND tma.nmmensagem not in ('CIR0051','LDL0032','LDL0024','LDL0021','SLC0001','SLC0005',
                            'LTR0001','CMP0002','STR0013')                         
  AND pr_tipo_mensagem IN ('E','T')    
  AND tma.cdcooper = cop.cdcooper (+)                     
  UNION
  /*  Neste union buscar somente as mensagens de convenio agendadas no dia anterior e efetivadas
       na data atual da conciliação  */ 
  SELECT tmaf.nmmensagem
        ,tma.nrcontrole_if 
        ,tma.cdcooper
        ,tmaf.dhmensagem
        ,tma.nrseq_mensagem
        ,tma.nrdconta
        ,tma.vlmensagem
        ,tma.nrispb_deb
        ,tma.nrispb_cre
        ,to_char(cop.cdagectl) nr_legado
        ,trunc(tma.dhmensagem) dataincage
        ,2 Agendado
  FROM tbspb_msg_enviada tma
      ,tbspb_msg_enviada_fase tmaf
      ,crapcop cop
  WHERE TRUNC(tmaf.dhmensagem) BETWEEN pr_data_ini
                           AND pr_data_fim
  AND tma.nrseq_mensagem = tmaf.nrseq_mensagem
  AND tmaf.cdfase = 55 
  AND trunc(tmaf.dhmensagem) > trunc(tma.dhmensagem)    
  AND pr_tipo_mensagem IN ('E','T')  
  AND tma.cdcooper = cop.cdcooper (+)           
  ORDER BY cdcooper, dhmensagem;
  
  /* Seleciona as informações das mensagens enviadas na JD, de acordo com o período solicitado*/
  CURSOR cr_msgenvjd (pr_data_ini date
                         ,pr_data_fim date) IS 
  SELECT tce.*
  FROM tbspb_conciliacao_enviada tce
  WHERE TRUNC(tce.dtmovto) BETWEEN pr_data_ini
                           AND pr_data_fim
  AND tce.cdmensagem not in ('CIR0051','LDL0032','LDL0024','LDL0021','SLC0001','SLC0005',
                            'LTR0001','CMP0002','STR0013')                            
  AND pr_tipo_mensagem IN ('E','T');  
  
  /*Validar se existe a mensagem enviada na JD*/
  CURSOR cr_valmsgenvjd (pr_nmmensagem VARCHAR2
                     ,pr_Nrcontrole_If VARCHAR2) IS 
  SELECT tce.*
  FROM tbspb_conciliacao_enviada tce
  WHERE tce.nrcontrole_if = pr_Nrcontrole_If
  AND   tce.cdmensagem    = pr_nmmensagem;
  rr_valmsgenvjd cr_valmsgenvjd%rowtype;
  
  /* Seleciona as informações das mensagens recebidas no Aimaro, de acordo com o período solicitado*/
  CURSOR cr_msgrecaimaro (pr_data_ini date
                         ,pr_data_fim date) IS 
  SELECT tmr.nmmensagem
        ,tmr.nrcontrole_str_pag
        ,tmr.cdcooper
        ,tmr.dhmensagem
        ,tmr.nrseq_mensagem
        ,tmr.nrdconta
        ,tmr.vlmensagem
        ,tmr.nrispb_deb
        ,tmr.nrispb_cre
        ,to_char(cop.cdagectl) nr_legado
  FROM tbspb_msg_recebida tmr
      ,crapcop cop
  WHERE TRUNC(tmr.dhmensagem) BETWEEN pr_data_ini
                           AND pr_data_fim
  AND tmr.nrcontrole_str_pag is not null 
  AND tmr.nmmensagem not in ('CIR0051','LDL0032','LDL0024','LDL0021','SLC0001','SLC0005',
                            'LTR0001','CMP0002','STR0013')  
  AND pr_tipo_mensagem IN ('R','T') 
  AND tmr.cdcooper = cop.cdcooper (+)                       
  ORDER BY cdcooper, dhmensagem;
  
  /*Validar se existe a mensagem recebida na JD*/
  CURSOR cr_valmsgrecjd (pr_nrcontrole_strpag VARCHAR2) IS 
  SELECT tcr.*
  FROM tbspb_conciliacao_recebida tcr
  WHERE tcr.nrcontrole_strpag = pr_nrcontrole_strpag;
  rr_valmsgrecjd cr_valmsgrecjd%rowtype;
  

  /* Seleciona as informações das mensagens recebidas na JD, de acordo com o período solicitado*/
  CURSOR cr_msgrecjd (pr_data_ini date
                     ,pr_data_fim date) IS 
  SELECT tcr.*
  FROM tbspb_conciliacao_recebida tcr
  WHERE TRUNC(tcr.dtmovto) BETWEEN pr_data_ini
                           AND pr_data_fim
  AND tcr.cdmensagem not in ('CIR0051','LDL0032','LDL0024','LDL0021','SLC0001','SLC0005',
                            'LTR0001','CMP0002','STR0013')                            
  AND pr_tipo_mensagem IN ('R','T');    
  
  
  TYPE typ_criticaconciliacao IS
    RECORD (Descricao    VARCHAR2(200)
            ,Critica     VARCHAR2(200)
            ,DataMsg     VARCHAR2(50)
            ,HoraMsg     VARCHAR2(50)
            ,AreaNeg     VARCHAR2(50)
            ,Mensagem    VARCHAR2(50)
            ,NrControleIF     VARCHAR2(50)
            ,NrControlePagStr VARCHAR2(50)
            ,ISPBCred         VARCHAR2(50)
            ,ClienteCred      VARCHAR2(200)
            ,CPFClienteCred   VARCHAR2(50)
            ,AgenciaCred      VARCHAR2(50)
            ,ContaCred        VARCHAR2(50)        
            ,ISPBDeb          VARCHAR2(50)
            ,ClienteDeb       VARCHAR2(200)
            ,CPFClienteDeb    VARCHAR2(50)
            ,AgenciaDeb       VARCHAR2(50)
            ,ContaDeb         VARCHAR2(50)
            ,Valor            VARCHAR2(50)
            ,Situacao         VARCHAR2(50)
            ,DataAgendamento  VARCHAR2(50)
            ,TipoMensagem     VARCHAR2(03)); 

  --Tipo de tabela para armazenar as criticas de conciliação
  TYPE typ_tab_criticaconciliacao IS TABLE OF typ_criticaconciliacao INDEX by pls_integer;  
  vr_tab_criticaconciliacao           typ_tab_criticaconciliacao;  
  

  TYPE typ_msgenviadaaimaro IS
      RECORD ( cdmensagem    VARCHAR2(20)
              ,NrControleIF  VARCHAR2(50) ); 

  --Tipo de tabela para armazenar as informações das mensagens enviadas do Aimaro
  TYPE typ_tab_msgenviadaaimaro IS TABLE OF typ_msgenviadaaimaro INDEX by VARCHAR2(50);  
  vr_tab_msgenviadaaimaro           typ_tab_msgenviadaaimaro; 
    

  TYPE typ_msgrecebidaaimaro IS
      RECORD ( nrcontrole_strpag  VARCHAR2(50) ); 

  --Tipo de tabela para armazenar as informações das mensagens enviadas do Aimaro
  TYPE typ_tab_msgrecebidaaimaro IS TABLE OF typ_msgrecebidaaimaro INDEX by VARCHAR2(50);  
  vr_tab_msgrecebidaaimaro           typ_tab_msgrecebidaaimaro;     
    
  -- Tratamento de erros
  vr_exc_erro  EXCEPTION;
  vr_exc_email EXCEPTION; 
  vr_dscritic VARCHAR2(4000);
  vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  --
  -- Variáveis do programa
  vr_fgenviada         BOOLEAN;
  vr_fgrecebida        BOOLEAN;
  vr_situacao_mensagem VARCHAR2(50);  
  vr_index             INTEGER;
  vr_qtdreg_jd         INTEGER;
  vr_fgsitenv          BOOLEAN;
  vr_ind_msgenvi       VARCHAR2(50); 
  vr_fgsitrec          BOOLEAN;
  vr_ind_msgrec        VARCHAR2(50); 
  
  vr_dtmensagem_de    DATE;
  vr_dtmensagem_ate   DATE;
  
  vr_qtde_regs          INTEGER;
  vr_situacao_jd        VARCHAR2(50);
  vr_aux_dscorpo  VARCHAR2(1000); 
  
  --
BEGIN
  vr_index:= 0;
  vr_tab_criticaconciliacao.delete;
  vr_dtmensagem_de := NVL(TO_DATE(pr_data_ini ,'dd/mm/yyyy'),TO_DATE('25-09-2018','dd-mm-yyyy'));
  vr_dtmensagem_ate:= NVL(TO_DATE(pr_data_fim,'dd/mm/yyyy'),TO_DATE('01-12-2999','dd-mm-yyyy'));
  --
  BEGIN -- Bloco Enviadas
    /* Conciliar mensagens enviadas do Aimaro com a JDSPB */
    FOR rr_msgenvaimaro in cr_msgenvaimaro (vr_dtmensagem_de, vr_dtmensagem_ate) LOOP
      -- Armazenar informações das mensagens enviadas para serem utilizadas na validação da JD x Aimaro
      -- Atualiza o indice
      vr_ind_msgenvi := rr_msgenvaimaro.nrcontrole_if||'-'||rr_msgenvaimaro.nmmensagem;
      -- Atualiza a temp-table 
      IF NOT vr_tab_msgenviadaaimaro.exists(vr_ind_msgenvi) THEN 
        vr_tab_msgenviadaaimaro(vr_ind_msgenvi).cdmensagem   := rr_msgenvaimaro.nmmensagem;
        vr_tab_msgenviadaaimaro(vr_ind_msgenvi).NrControleIF := rr_msgenvaimaro.nrcontrole_if;
      END IF;    
      --
      vr_fgenviada:= False;
      -- Busca a situação da mensagem no aimaro
      vr_situacao_mensagem := null;
      vr_situacao_mensagem := tela_logspb.fn_define_situacao_enviada( rr_msgenvaimaro.nrseq_mensagem);
      -- Valida se amensagem esta na JDSPB
      OPEN cr_valmsgenvjd (rr_msgenvaimaro.nmmensagem, rr_msgenvaimaro.Nrcontrole_If);
      FETCH cr_valmsgenvjd INTO rr_valmsgenvjd;
      IF cr_valmsgenvjd%FOUND THEN
         -- Encontrou a mensagem na JD
         vr_fgenviada:= True;
      END IF;
      CLOSE cr_valmsgenvjd;
      --
      IF not vr_fgenviada THEN
          --Gravar critica de falta de mensagem na JD na tabela temporaria    
          vr_index:= vr_index + 1;
          vr_tab_criticaconciliacao(vr_index).Descricao := '<NumCtrlIF> '||rr_msgenvaimaro.nrcontrole_if||' não encontrado na base JDSPB.';
          vr_tab_criticaconciliacao(vr_index).Critica := null;
          IF rr_msgenvaimaro.agendado = 2 THEN --R1 de um agendamento
             vr_tab_criticaconciliacao(vr_index).DataAgendamento  := TO_CHAR(rr_msgenvaimaro.dhmensagem,'dd-mm-yyyy');
             vr_tab_criticaconciliacao(vr_index).DataMsg := TO_CHAR(rr_msgenvaimaro.Dataincage,'dd-mm-yyyy');    
             vr_tab_criticaconciliacao(vr_index).HoraMsg := TO_CHAR(rr_msgenvaimaro.Dataincage,'hh24:mi:ss');
          ELSE        
             vr_tab_criticaconciliacao(vr_index).DataMsg := TO_CHAR(rr_msgenvaimaro.dhmensagem,'dd-mm-yyyy');    
             vr_tab_criticaconciliacao(vr_index).HoraMsg := TO_CHAR(rr_msgenvaimaro.dhmensagem,'hh24:mi:ss');
          END IF;
          vr_tab_criticaconciliacao(vr_index).AreaNeg          := rr_msgenvaimaro.nr_legado;    
          vr_tab_criticaconciliacao(vr_index).Mensagem         := rr_msgenvaimaro.nmmensagem;   
          vr_tab_criticaconciliacao(vr_index).NrControleIF     := rr_msgenvaimaro.nrcontrole_if;     
          vr_tab_criticaconciliacao(vr_index).NrControlePagStr := null; 
          vr_tab_criticaconciliacao(vr_index).ISPBCred         := rr_msgenvaimaro.nrispb_cre;
          vr_tab_criticaconciliacao(vr_index).ClienteCred      := null;
          vr_tab_criticaconciliacao(vr_index).CPFClienteCred   := null;
          vr_tab_criticaconciliacao(vr_index).AgenciaCred      := null;
          vr_tab_criticaconciliacao(vr_index).ContaCred        := null;
          vr_tab_criticaconciliacao(vr_index).ISPBDeb          := rr_msgenvaimaro.nrispb_deb;
          vr_tab_criticaconciliacao(vr_index).ClienteDeb       := null;
          vr_tab_criticaconciliacao(vr_index).CPFClienteDeb    := null;
          vr_tab_criticaconciliacao(vr_index).AgenciaDeb       := null;
          vr_tab_criticaconciliacao(vr_index).ContaDeb         := rr_msgenvaimaro.nrdconta;
          vr_tab_criticaconciliacao(vr_index).Valor            := TRIM(REPLACE(TO_CHAR(rr_msgenvaimaro.vlmensagem,'FM99999999990.00'),'.',','));
          vr_tab_criticaconciliacao(vr_index).Situacao         := vr_situacao_mensagem;
          vr_tab_criticaconciliacao(vr_index).TipoMensagem     := 'ENV'; 
          --
      ELSE
        -- Validar a situacao
        vr_fgsitenv := fn_depara_situacao_enviada (vr_situacao_mensagem, rr_valmsgenvjd.dssituacao);
        --
        IF  not vr_fgsitenv THEN
          -- 
          --Gravar critica de situação na tabela temporaria    
          vr_situacao_jd := fn_depara_descricao_jd(rr_valmsgenvjd.dssituacao);
          vr_index:= vr_index + 1;
          vr_tab_criticaconciliacao(vr_index).Descricao := '<NumCtrlIF> '||rr_msgenvaimaro.nrcontrole_if||' divergente na SITUACAO.';
          vr_tab_criticaconciliacao(vr_index).Critica := 'AIMARO: '||vr_situacao_mensagem|| ' - JDSPB: '||vr_situacao_jd;
          IF rr_msgenvaimaro.agendado = 2 THEN --R1 de um agendamento
             vr_tab_criticaconciliacao(vr_index).DataAgendamento  := TO_CHAR(rr_msgenvaimaro.dhmensagem,'dd-mm-yyyy');
             vr_tab_criticaconciliacao(vr_index).DataMsg := TO_CHAR(rr_msgenvaimaro.Dataincage,'dd-mm-yyyy');    
             vr_tab_criticaconciliacao(vr_index).HoraMsg := TO_CHAR(rr_msgenvaimaro.Dataincage,'hh24:mi:ss');
          ELSE        
             vr_tab_criticaconciliacao(vr_index).DataMsg := TO_CHAR(rr_msgenvaimaro.dhmensagem,'dd-mm-yyyy');    
             vr_tab_criticaconciliacao(vr_index).HoraMsg := TO_CHAR(rr_msgenvaimaro.dhmensagem,'hh24:mi:ss');
          END IF;
          vr_tab_criticaconciliacao(vr_index).AreaNeg          := rr_msgenvaimaro.nr_legado;    
          vr_tab_criticaconciliacao(vr_index).Mensagem         := rr_msgenvaimaro.nmmensagem;   
          vr_tab_criticaconciliacao(vr_index).NrControleIF     := rr_msgenvaimaro.nrcontrole_if;     
          vr_tab_criticaconciliacao(vr_index).NrControlePagStr := null; 
          vr_tab_criticaconciliacao(vr_index).ISPBCred         := rr_msgenvaimaro.nrispb_cre;
          vr_tab_criticaconciliacao(vr_index).ClienteCred      := rr_valmsgenvjd.Nmclicredtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteCred   := rr_valmsgenvjd.Nrcnpj_Cpfclicredtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaCred      := rr_valmsgenvjd.Nragcredtd;
          vr_tab_criticaconciliacao(vr_index).ContaCred        := rr_valmsgenvjd.Nrctcredtd;
          vr_tab_criticaconciliacao(vr_index).ISPBDeb          := rr_msgenvaimaro.nrispb_deb;
          vr_tab_criticaconciliacao(vr_index).ClienteDeb       := rr_valmsgenvjd.Nmclidebtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteDeb    := rr_valmsgenvjd.Nrcnpj_Cpfclidebtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaDeb       := rr_valmsgenvjd.nragdebtd;
          vr_tab_criticaconciliacao(vr_index).ContaDeb         := rr_msgenvaimaro.nrdconta;
          vr_tab_criticaconciliacao(vr_index).Valor            := TRIM(REPLACE(TO_CHAR(rr_msgenvaimaro.vlmensagem,'FM99999999990.00'),'.',','));
          vr_tab_criticaconciliacao(vr_index).Situacao         := vr_situacao_mensagem;   
          vr_tab_criticaconciliacao(vr_index).TipoMensagem     := 'ENV';      
        END IF;
        -- Validar o legado
        IF rr_msgenvaimaro.nr_legado <> rr_valmsgenvjd.nrlegado THEN
          vr_situacao_jd := fn_depara_descricao_jd(rr_valmsgenvjd.dssituacao);
          --
          --Gravar critica de legado na tabela temporaria    
          vr_index:= vr_index + 1;
          vr_tab_criticaconciliacao(vr_index).Descricao := '<NumCtrlIF> '||rr_msgenvaimaro.nrcontrole_if||' divergente no LEGADO.';
          vr_tab_criticaconciliacao(vr_index).Critica := 'AIMARO: '||rr_msgenvaimaro.nr_legado|| ' - JDSPB: '||rr_valmsgenvjd.nrlegado;
          IF rr_msgenvaimaro.agendado = 2 THEN --R1 de um agendamento
             vr_tab_criticaconciliacao(vr_index).DataAgendamento  := TO_CHAR(rr_msgenvaimaro.dhmensagem,'dd-mm-yyyy');
             vr_tab_criticaconciliacao(vr_index).DataMsg := TO_CHAR(rr_msgenvaimaro.Dataincage,'dd-mm-yyyy');    
             vr_tab_criticaconciliacao(vr_index).HoraMsg := TO_CHAR(rr_msgenvaimaro.Dataincage,'hh24:mi:ss');
          ELSE        
             vr_tab_criticaconciliacao(vr_index).DataMsg := TO_CHAR(rr_msgenvaimaro.dhmensagem,'dd-mm-yyyy');    
             vr_tab_criticaconciliacao(vr_index).HoraMsg := TO_CHAR(rr_msgenvaimaro.dhmensagem,'hh24:mi:ss');
          END IF;
          vr_tab_criticaconciliacao(vr_index).AreaNeg          := rr_msgenvaimaro.nr_legado;    
          vr_tab_criticaconciliacao(vr_index).Mensagem         := rr_msgenvaimaro.nmmensagem;   
          vr_tab_criticaconciliacao(vr_index).NrControleIF     := rr_msgenvaimaro.nrcontrole_if;     
          vr_tab_criticaconciliacao(vr_index).NrControlePagStr := null; 
          vr_tab_criticaconciliacao(vr_index).ISPBCred         := rr_msgenvaimaro.nrispb_cre;
          vr_tab_criticaconciliacao(vr_index).ClienteCred      := rr_valmsgenvjd.Nmclicredtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteCred   := rr_valmsgenvjd.Nrcnpj_Cpfclicredtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaCred      := rr_valmsgenvjd.Nragcredtd;
          vr_tab_criticaconciliacao(vr_index).ContaCred        := rr_valmsgenvjd.Nrctcredtd;
          vr_tab_criticaconciliacao(vr_index).ISPBDeb          := rr_msgenvaimaro.nrispb_deb;
          vr_tab_criticaconciliacao(vr_index).ClienteDeb       := rr_valmsgenvjd.Nmclidebtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteDeb    := rr_valmsgenvjd.Nrcnpj_Cpfclidebtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaDeb       := rr_valmsgenvjd.nragdebtd;
          vr_tab_criticaconciliacao(vr_index).ContaDeb         := rr_msgenvaimaro.nrdconta;
          vr_tab_criticaconciliacao(vr_index).Valor            := TRIM(REPLACE(TO_CHAR(rr_msgenvaimaro.vlmensagem,'FM99999999990.00'),'.',','));
          vr_tab_criticaconciliacao(vr_index).Situacao         := vr_situacao_mensagem; 
          vr_tab_criticaconciliacao(vr_index).TipoMensagem     := 'ENV';
        END IF;
          
      END IF;   
    END LOOP;

    /* Conciliar mensagens enviadas da JDSPB com Aimaro */
    FOR rr_msgenvjd in cr_msgenvjd (vr_dtmensagem_de, vr_dtmensagem_ate) LOOP
      vr_fgenviada:= False;
      -- Validar se mensagem esta no AIMARO
      -- Montar o indice
      vr_ind_msgenvi := rr_msgenvjd.nrcontrole_if||'-'||rr_msgenvjd.cdmensagem;
      -- Verifica se existe na tabela temporaria de mensagens enviadas do Aimaro (gravada na leitura das mensagens enviadas)
      IF vr_tab_msgenviadaaimaro.exists(vr_ind_msgenvi) THEN 
         vr_fgenviada:= True;
      ELSE
         /* Verifica se não esta em registros de dias anteriores. A tabela temporária possui os dados do 
            dia em questão que a conciliação esta sendo executada. */
         SELECT COUNT(*) INTO vr_qtde_regs
         FROM TBSPB_MSG_ENVIADA TME
         WHERE TME.NRCONTROLE_IF =   rr_msgenvjd.nrcontrole_if;
         IF vr_qtde_regs <> 0 THEN
            vr_fgenviada:= True;
         END IF;   
                
      END IF; 
      --
      IF not vr_fgenviada THEN
          --Gravar critica de falta de mensagem no Aimaro na tabela temporaria  
          vr_situacao_jd := fn_depara_descricao_jd(rr_msgenvjd.dssituacao);  
          vr_index:= vr_index + 1;
          vr_tab_criticaconciliacao(vr_index).Descricao        := '<NumCtrlIF> '||rr_msgenvjd.nrcontrole_if||' não encontrado na base AIMARO.';
          vr_tab_criticaconciliacao(vr_index).Critica          := null;         
          vr_tab_criticaconciliacao(vr_index).DataMsg          := TO_CHAR(rr_msgenvjd.dtmovto,'dd-mm-yyyy');    
          vr_tab_criticaconciliacao(vr_index).HoraMsg          := TO_CHAR(rr_msgenvjd.dhbacen,'hh24:mi:ss');
          vr_tab_criticaconciliacao(vr_index).AreaNeg          := rr_msgenvjd.nrlegado;    
          vr_tab_criticaconciliacao(vr_index).Mensagem         := rr_msgenvjd.cdmensagem;   
          vr_tab_criticaconciliacao(vr_index).NrControleIF     := rr_msgenvjd.nrcontrole_if;     
          vr_tab_criticaconciliacao(vr_index).NrControlePagStr := rr_msgenvjd.nrcontrole_strpag; 
          vr_tab_criticaconciliacao(vr_index).ISPBCred         := rr_msgenvjd.nrispbifcredtd;
          vr_tab_criticaconciliacao(vr_index).ClienteCred      := rr_msgenvjd.nmclicredtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteCred   := rr_msgenvjd.nrcnpj_cpfclicredtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaCred      := rr_msgenvjd.nragcredtd;
          vr_tab_criticaconciliacao(vr_index).ContaCred        := rr_msgenvjd.nrctcredtd;
          vr_tab_criticaconciliacao(vr_index).ISPBDeb          := rr_msgenvjd.nrispbifdebtd;
          vr_tab_criticaconciliacao(vr_index).ClienteDeb       := rr_msgenvjd.nmclidebtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteDeb    := rr_msgenvjd.nrcnpj_cpfclidebtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaDeb       := rr_msgenvjd.nragdebtd;
          vr_tab_criticaconciliacao(vr_index).ContaDeb         := rr_msgenvjd.nrctdebtd;
          vr_tab_criticaconciliacao(vr_index).Valor            := TRIM(REPLACE(TO_CHAR(rr_msgenvjd.vllancamento,'FM99999999990.00'),'.',','));
          vr_tab_criticaconciliacao(vr_index).Situacao         := vr_situacao_jd;
          vr_tab_criticaconciliacao(vr_index).TipoMensagem     := 'ENV'; 
          --       
      END IF;   
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_dscritic IS NULL THEN
         vr_dscritic:= 'Erro ao processar conciliação das mensagens enviadas <NrControleIF> '||vr_ind_msgenvi||' - Erro: '||sqlerrm;
      END IF;
      RAISE vr_exc_erro;
  END;
  --
  -- CONCILIAR MENSAGENS RECEBIDAS
  --
  BEGIN -- Bloco Recebidas
      
    /* Conciliar mensagens recebidas do Aimaro com a JDSPB */
    FOR rr_msgrecaimaro in cr_msgrecaimaro (vr_dtmensagem_de, vr_dtmensagem_ate) LOOP
      -- Armazenar informações das mensagens recebidas para serem utilizadas na validação da JD x Aimaro
      -- Atualiza o indice
      vr_ind_msgrec := rr_msgrecaimaro.nrcontrole_str_pag;
      -- Atualiza a temp-table 
      IF NOT vr_tab_msgrecebidaaimaro.exists(vr_ind_msgrec) THEN 
        vr_tab_msgrecebidaaimaro(vr_ind_msgrec).nrcontrole_strpag := rr_msgrecaimaro.nrcontrole_str_pag;
      END IF;    
      --
      vr_fgrecebida:= False;
      -- Busca a situação da mensagem no aimaro
      vr_situacao_mensagem := null;
      vr_situacao_mensagem := tela_logspb.fn_define_situacao_recebida( rr_msgrecaimaro.nrseq_mensagem, rr_msgrecaimaro.nrcontrole_str_pag, rr_msgrecaimaro.nmmensagem);
      -- Valida se amensagem esta na JDSPB
      OPEN cr_valmsgrecjd (rr_msgrecaimaro.nrcontrole_str_pag);
      FETCH cr_valmsgrecjd INTO rr_valmsgrecjd;
      IF cr_valmsgrecjd%FOUND THEN
         -- Encontrou a mensagem na JD
         vr_fgrecebida:= True;
      END IF;
      CLOSE cr_valmsgrecjd;
      --
      IF not vr_fgrecebida THEN
          --Gravar critica de falta de mensagem na JD na tabela temporaria    
          vr_index:= vr_index + 1;
          vr_tab_criticaconciliacao(vr_index).Descricao        := '<NumCtrlStrPag> '||rr_msgrecaimaro.nrcontrole_str_pag||' não encontrado na base JDSPB.';
          vr_tab_criticaconciliacao(vr_index).Critica          := null;
          vr_tab_criticaconciliacao(vr_index).DataMsg          := TO_CHAR(rr_msgrecaimaro.dhmensagem,'dd-mm-yyyy');    
          vr_tab_criticaconciliacao(vr_index).HoraMsg          := TO_CHAR(rr_msgrecaimaro.dhmensagem,'hh24:mi:ss');
          vr_tab_criticaconciliacao(vr_index).AreaNeg          := rr_msgrecaimaro.nr_legado;    
          vr_tab_criticaconciliacao(vr_index).Mensagem         := rr_msgrecaimaro.nmmensagem;   
          vr_tab_criticaconciliacao(vr_index).NrControleIF     := null;     
          vr_tab_criticaconciliacao(vr_index).NrControlePagStr := rr_msgrecaimaro.nrcontrole_str_pag; 
          vr_tab_criticaconciliacao(vr_index).ISPBCred         := rr_msgrecaimaro.nrispb_cre;
          vr_tab_criticaconciliacao(vr_index).ClienteCred      := null; --rr_msgrecaimaro.nrdconta;
          vr_tab_criticaconciliacao(vr_index).CPFClienteCred   := null;
          vr_tab_criticaconciliacao(vr_index).AgenciaCred      := null;
          vr_tab_criticaconciliacao(vr_index).ContaCred        := rr_msgrecaimaro.nrdconta;
          vr_tab_criticaconciliacao(vr_index).ISPBDeb          := rr_msgrecaimaro.nrispb_deb;
          vr_tab_criticaconciliacao(vr_index).ClienteDeb       := null;
          vr_tab_criticaconciliacao(vr_index).CPFClienteDeb    := null;
          vr_tab_criticaconciliacao(vr_index).AgenciaDeb       := null;
          vr_tab_criticaconciliacao(vr_index).ContaDeb         := null;
          vr_tab_criticaconciliacao(vr_index).Valor            := TRIM(REPLACE(TO_CHAR(rr_msgrecaimaro.vlmensagem,'FM99999999990.00'),'.',','));
          vr_tab_criticaconciliacao(vr_index).Situacao         := vr_situacao_mensagem; 
          vr_tab_criticaconciliacao(vr_index).TipoMensagem     := 'REC';
          --
      ELSE
        -- Validar a situacao
        vr_fgsitrec := fn_depara_situacao_recebida (vr_situacao_mensagem, rr_valmsgrecjd.dssituacao);
        --
        IF  not vr_fgsitrec THEN
          --      
          --Gravar critica de situação na tabela temporaria  
          vr_situacao_jd := fn_depara_descricao_jd(rr_valmsgrecjd.dssituacao);  
          vr_index:= vr_index + 1;
          vr_tab_criticaconciliacao(vr_index).Descricao := '<NumCtrlStrPag> '||rr_msgrecaimaro.nrcontrole_str_pag||' divergente na SITUACAO.';
          vr_tab_criticaconciliacao(vr_index).Critica := 'AIMARO: '||vr_situacao_mensagem|| ' - JDSPB: '||vr_situacao_jd;
          vr_tab_criticaconciliacao(vr_index).DataMsg          := TO_CHAR(rr_msgrecaimaro.dhmensagem,'dd-mm-yyyy');    
          vr_tab_criticaconciliacao(vr_index).HoraMsg          := TO_CHAR(rr_msgrecaimaro.dhmensagem,'hh24:mi:ss');
          vr_tab_criticaconciliacao(vr_index).AreaNeg          := rr_msgrecaimaro.nr_legado;    
          vr_tab_criticaconciliacao(vr_index).Mensagem         := rr_msgrecaimaro.nmmensagem;   
          vr_tab_criticaconciliacao(vr_index).NrControleIF     := null;     
          vr_tab_criticaconciliacao(vr_index).NrControlePagStr := rr_msgrecaimaro.nrcontrole_str_pag; 
          vr_tab_criticaconciliacao(vr_index).ISPBCred         := rr_msgrecaimaro.nrispb_cre;
          vr_tab_criticaconciliacao(vr_index).ClienteCred      := rr_valmsgrecjd.nmclicredtd; --rr_msgrecaimaro.nrdconta; 
          vr_tab_criticaconciliacao(vr_index).CPFClienteCred   := rr_valmsgrecjd.nrcnpj_cpfclicredtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaCred      := rr_valmsgrecjd.nragcredtd;
          vr_tab_criticaconciliacao(vr_index).ContaCred        := rr_valmsgrecjd.nrctcredtd;
          vr_tab_criticaconciliacao(vr_index).ISPBDeb          := rr_msgrecaimaro.nrispb_deb;
          vr_tab_criticaconciliacao(vr_index).ClienteDeb       := rr_valmsgrecjd.nmclidebtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteDeb    := rr_valmsgrecjd.nrcnpj_cpfclidebtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaDeb       := rr_valmsgrecjd.nragdebtd;
          vr_tab_criticaconciliacao(vr_index).ContaDeb         := rr_valmsgrecjd.nrctdebtd;
          vr_tab_criticaconciliacao(vr_index).Valor            := TRIM(REPLACE(TO_CHAR(rr_msgrecaimaro.vlmensagem,'FM99999999990.00'),'.',','));
          vr_tab_criticaconciliacao(vr_index).Situacao         := vr_situacao_jd; 
          vr_tab_criticaconciliacao(vr_index).TipoMensagem     := 'REC';
        END IF;
        -- Validar o legado
        IF rr_msgrecaimaro.nr_legado <> rr_valmsgrecjd.nrlegado THEN
          --           
          vr_situacao_jd := fn_depara_descricao_jd(rr_valmsgrecjd.dssituacao);  
          --Gravar critica de legado na tabela temporaria    
          vr_index:= vr_index + 1;
          vr_tab_criticaconciliacao(vr_index).Descricao        := '<NumCtrlStrPag> '||rr_msgrecaimaro.nrcontrole_str_pag||' divergente no LEGADO.';
          vr_tab_criticaconciliacao(vr_index).Critica          := 'AIMARO: '||rr_msgrecaimaro.nr_legado|| ' - JDSPB: '||rr_valmsgrecjd.nrlegado;
          vr_tab_criticaconciliacao(vr_index).DataMsg          := TO_CHAR(rr_msgrecaimaro.dhmensagem,'dd-mm-yyyy');    
          vr_tab_criticaconciliacao(vr_index).HoraMsg          := TO_CHAR(rr_msgrecaimaro.dhmensagem,'hh24:mi:ss');
          vr_tab_criticaconciliacao(vr_index).AreaNeg          := rr_msgrecaimaro.nr_legado;    
          vr_tab_criticaconciliacao(vr_index).Mensagem         := rr_msgrecaimaro.nmmensagem;   
          vr_tab_criticaconciliacao(vr_index).NrControleIF     := null;     
          vr_tab_criticaconciliacao(vr_index).NrControlePagStr := rr_msgrecaimaro.nrcontrole_str_pag; 
          vr_tab_criticaconciliacao(vr_index).ISPBCred         := rr_msgrecaimaro.nrispb_cre;
          vr_tab_criticaconciliacao(vr_index).ClienteCred      := rr_valmsgrecjd.nmclicredtd; --rr_msgrecaimaro.nrdconta;
          vr_tab_criticaconciliacao(vr_index).CPFClienteCred   := rr_valmsgrecjd.nrcnpj_cpfclicredtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaCred      := rr_valmsgrecjd.nragcredtd;
          vr_tab_criticaconciliacao(vr_index).ContaCred        := rr_valmsgrecjd.nrctcredtd;
          vr_tab_criticaconciliacao(vr_index).ISPBDeb          := rr_msgrecaimaro.nrispb_deb;
          vr_tab_criticaconciliacao(vr_index).ClienteDeb       := rr_valmsgrecjd.nmclidebtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteDeb    := rr_valmsgrecjd.nrcnpj_cpfclidebtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaDeb       := rr_valmsgrecjd.nragdebtd;
          vr_tab_criticaconciliacao(vr_index).ContaDeb         := rr_valmsgrecjd.nrctdebtd;
          vr_tab_criticaconciliacao(vr_index).Valor            := TRIM(REPLACE(TO_CHAR(rr_msgrecaimaro.vlmensagem,'FM99999999990.00'),'.',','));
          vr_tab_criticaconciliacao(vr_index).Situacao         := vr_situacao_jd; 
          vr_tab_criticaconciliacao(vr_index).TipoMensagem     := 'REC';
        END IF;
          
      END IF;   
    END LOOP;

    /* Conciliar mensagens recebidas da JDSPB com Aimaro */
    FOR rr_msgrecjd in cr_msgrecjd (vr_dtmensagem_de, vr_dtmensagem_ate) LOOP
      vr_fgrecebida:= False;
      -- Validar se mensagem esta no AIMARO
      -- Montar o indice
      vr_ind_msgrec := rr_msgrecjd.nrcontrole_strpag;
      -- Verifica se existe na tabela temporaria de mensagens recebiadas do Aimaro (gravada na leitura das mensagens recebidas)
      IF vr_tab_msgrecebidaaimaro.exists(vr_ind_msgrec) THEN 
         vr_fgrecebida:= True;
      ELSE   
         /* Verifica se não esta em registros de dias anteriores. A tabela temporária possui os dados do 
            dia em questão que a conciliação esta sendo executada. */
         SELECT COUNT(*) INTO vr_qtde_regs
         FROM TBSPB_MSG_RECEBIDA TMR
         WHERE TMR.NRCONTROLE_STR_PAG = rr_msgrecjd.nrcontrole_strpag;
         IF vr_qtde_regs <> 0 THEN
            vr_fgenviada:= True;
         END IF;            
      END IF; 
      --
      IF not vr_fgrecebida THEN
          vr_situacao_jd := fn_depara_descricao_jd(rr_msgrecjd.dssituacao);
          --
          --Gravar critica de falta de mensagem no Aimaro na tabela temporaria    
          vr_index:= vr_index + 1;
          vr_tab_criticaconciliacao(vr_index).Descricao        := '<NumCtrlStrPag> '||rr_msgrecjd.nrcontrole_strpag||' não encontrado na base AIMARO.';
          vr_tab_criticaconciliacao(vr_index).Critica          := null;
          
          vr_tab_criticaconciliacao(vr_index).DataMsg          := TO_CHAR(rr_msgrecjd.dtmovto,'dd-mm-yyyy');    
          vr_tab_criticaconciliacao(vr_index).HoraMsg          := TO_CHAR(rr_msgrecjd.dhbacen,'hh24:mi:ss');
          vr_tab_criticaconciliacao(vr_index).AreaNeg          := rr_msgrecjd.nrlegado;    
          vr_tab_criticaconciliacao(vr_index).Mensagem         := rr_msgrecjd.cdmensagem;   
          vr_tab_criticaconciliacao(vr_index).NrControleIF     := rr_msgrecjd.nrcontrole_if;     
          vr_tab_criticaconciliacao(vr_index).NrControlePagStr := rr_msgrecjd.nrcontrole_strpag; 
          vr_tab_criticaconciliacao(vr_index).ISPBCred         := rr_msgrecjd.nrispbifcredtd;
          vr_tab_criticaconciliacao(vr_index).ClienteCred      := rr_msgrecjd.nmclicredtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteCred   := rr_msgrecjd.nrcnpj_cpfclicredtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaCred      := rr_msgrecjd.nragcredtd;
          vr_tab_criticaconciliacao(vr_index).ContaCred        := rr_msgrecjd.nrctcredtd;
          vr_tab_criticaconciliacao(vr_index).ISPBDeb          := rr_msgrecjd.nrispbifdebtd;
          vr_tab_criticaconciliacao(vr_index).ClienteDeb       := rr_msgrecjd.nmclidebtd;
          vr_tab_criticaconciliacao(vr_index).CPFClienteDeb    := rr_msgrecjd.nrcnpj_cpfclidebtd;
          vr_tab_criticaconciliacao(vr_index).AgenciaDeb       := rr_msgrecjd.nragdebtd;
          vr_tab_criticaconciliacao(vr_index).ContaDeb         := rr_msgrecjd.nrctdebtd;
          vr_tab_criticaconciliacao(vr_index).Valor            := TRIM(REPLACE(TO_CHAR(rr_msgrecjd.vllancamento,'FM99999999990.00'),'.',','));
          vr_tab_criticaconciliacao(vr_index).Situacao         := vr_situacao_jd; 
          vr_tab_criticaconciliacao(vr_index).TipoMensagem     := 'REC';
          --       
      END IF;   
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_dscritic IS NULL THEN
         vr_dscritic:= 'Erro ao processar conciliação das mensagens recebidas <NumCtrlStrPag> '||vr_ind_msgrec||' - Erro: '||sqlerrm;
      END IF;
      RAISE vr_exc_erro;
  END;  

  /* Rotina para gerar o arquivo CSV da conciliação e enviar e-mail */
  IF vr_index <> 0 THEN
     
      DECLARE
        --vr_dsdircop          VARCHAR2(100);
        vr_dircop_txt        VARCHAR2(1000);
        vr_nom_arquivo       VARCHAR2(1000);
        vr_nom_arquivo_rec   VARCHAR2(1000);
        vr_ind_modo_abertura VARCHAR2(1000);
        vr_cabecalho         VARCHAR2(4000);
        vr_dslinha           VARCHAR2(32000);
        vr_cdcritic          INTEGER;
        vr_ind_arqlog        UTL_FILE.file_type; 
        vr_ind_arqlog_rec    UTL_FILE.file_type; 
      BEGIN
        --
        vr_cabecalho := 'Resultado;Critica;"Data Mensagem";Hora Mensagem;"Area Neg";Mensagem;'
                     || '"Nr Controle IF";"Nr Controle PagStr";"ISPBCred";"Cliente Creditado";'
                     || '"CPF/CNPJ Cliente Creditado";"Agencia Creditada";"Conta Creditada";"ISPBDeb";"Cliente Debitado";'
                     || '"CPF/CNPJ Cliente Debitado";"Agencia Debitada";"Conta Debitada";"Valor";"Situacao";"DataAgendamento"';
       --
        vr_dircop_txt        := '/usr/sistemas/SPB/CONSPB/';
        vr_nom_arquivo       := 'CONCILIACAOENVSPB_'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')||'.csv';
        vr_nom_arquivo_rec   := 'CONCILIACAORECSPB_'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')||'.csv';
        vr_ind_modo_abertura := 'W'; --> W_Write, A=Append
        -- Abrir o arquivo de mensagens enviadas
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_dircop_txt         --> Diretório do arquivo
                                ,pr_nmarquiv => vr_nom_arquivo        --> Nome do arquivo
                                ,pr_tipabert => vr_ind_modo_abertura  --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_ind_arqlog         --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic := 0; 
          RAISE vr_exc_erro;
        END IF;
        --
        -- Abrir o arquivo de mensagens recebidas
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_dircop_txt         --> Diretório do arquivo
                                ,pr_nmarquiv => vr_nom_arquivo_rec        --> Nome do arquivo
                                ,pr_tipabert => vr_ind_modo_abertura  --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_ind_arqlog_rec         --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic := 0; 
          RAISE vr_exc_erro;
        END IF;
        
        --
        FOR Idx IN 1 .. vr_tab_criticaconciliacao.COUNT LOOP
          -- Adiciona a linha arquivo csv
          BEGIN
              
            vr_dslinha := vr_tab_criticaconciliacao(Idx).Descricao
                  ||';'||vr_tab_criticaconciliacao(Idx).Critica
                  ||';'||vr_tab_criticaconciliacao(Idx).DataMsg
                  ||';'||vr_tab_criticaconciliacao(Idx).HoraMsg 
                  ||';'||vr_tab_criticaconciliacao(Idx).AreaNeg 
                  ||';'||vr_tab_criticaconciliacao(Idx).Mensagem
                  ||';'||vr_tab_criticaconciliacao(Idx).NrControleIF
                  ||';'||vr_tab_criticaconciliacao(Idx).NrControlePagStr
                  ||';'||vr_tab_criticaconciliacao(Idx).ISPBCred
                  ||';'||vr_tab_criticaconciliacao(Idx).ClienteCred
                  ||';'||vr_tab_criticaconciliacao(Idx).CPFClienteCred 
                  ||';'||vr_tab_criticaconciliacao(Idx).AgenciaCred 
                  ||';'||vr_tab_criticaconciliacao(Idx).ContaCred 
                  ||';'||vr_tab_criticaconciliacao(Idx).ISPBDeb 
                  ||';'||vr_tab_criticaconciliacao(Idx).ClienteDeb 
                  ||';'||vr_tab_criticaconciliacao(Idx).CPFClienteDeb 
                  ||';'||vr_tab_criticaconciliacao(Idx).AgenciaDeb
                  ||';'||vr_tab_criticaconciliacao(Idx).ContaDeb 
                  ||';'||vr_tab_criticaconciliacao(Idx).Valor 
                  ||';'||vr_tab_criticaconciliacao(Idx).Situacao
                  ||';'||vr_tab_criticaconciliacao(Idx).DataAgendamento;
                    
            IF Idx = 1 THEN
               gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cabecalho);
               gene0001.pc_escr_linha_arquivo(vr_ind_arqlog_rec, vr_cabecalho);
            END IF;   

            IF vr_tab_criticaconciliacao(Idx).TipoMensagem = 'ENV' THEN
               gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dslinha);
            ELSE
               gene0001.pc_escr_linha_arquivo(vr_ind_arqlog_rec, vr_dslinha);
            END IF;   
            --
          EXCEPTION
          WHEN OTHERS THEN
            -- Retornar erro
            vr_dscritic := 'Problema ao escrever no arquivo de conciliacao <'||vr_dircop_txt||'/'||vr_nom_arquivo||'>: ' || sqlerrm;
            RAISE vr_exc_erro;
          END;
        END LOOP;
        --
        BEGIN
          gene0001.pc_fecha_arquivo(vr_ind_arqlog);
          gene0001.pc_fecha_arquivo(vr_ind_arqlog_rec);
        EXCEPTION
          WHEN OTHERS THEN
            -- Retornar erro
            vr_dscritic := 'Problema ao fechar o arquivo de conciliacao <'||vr_dircop_txt||'/'||vr_nom_arquivo||'>: ' || sqlerrm;
            RAISE vr_exc_erro;
        END;
        --
        vr_aux_dscorpo := 'Sua solicitação foi processada com sucesso e o(s) arquivo(s) '||vr_nom_arquivo||' - '||vr_nom_arquivo_rec||' já está(ão) disponível(is) no diretório: X:\SPB\CONSPB\';
        RAISE vr_exc_email;
      END;
  
   END IF;
  
  
EXCEPTION
  
    WHEN vr_exc_email THEN
      DECLARE
        vr_aux_dsdemail VARCHAR2(1000);
      BEGIN
        IF pr_tipo_concilacao = 'M' THEN 
          vr_aux_dsdemail := pr_dsendere;
        ELSE
          vr_aux_dsdemail:= gene0001.fn_param_sistema('CRED',0,'SPB_TED_SEM_CONTA');
        END IF;
        --
        pr_cdcritic     := null;
        pr_dscritic     := null;
        --
        -- Enviar Email para o responsavel
        gene0003.pc_solicita_email(pr_cdcooper        => 3
                                  ,pr_cdprogra        => 'CONSPB'
                                  ,pr_des_destino     => vr_aux_dsdemail
                                  ,pr_des_assunto     => 'CONSPB - notificação arquivo de conciliação'
                                  ,pr_des_corpo       => vr_aux_dscorpo
                                  ,pr_des_anexo       => ''
                                  ,pr_flg_enviar      => 'S'
                                  ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                  ,pr_des_erro        => vr_dscritic);
        -- Se ocorreu erro
        IF trim(vr_dscritic) IS NOT NULL THEN
          NULL;
        END IF;
        COMMIT;
      END;
      --
  WHEN vr_exc_erro THEN
    Rollback;
    pr_dscritic := vr_dscritic;
    --
    CECRED.pc_log_programa(pr_dstiplog  => 'E'
                      ,pr_cdprograma    => 'SSBP0002'
                      ,pr_cdcooper      => 3
                      ,pr_tpexecucao    => 2 
                      ,pr_tpocorrencia  => 2
                      ,pr_cdcriticidade => 3
                      ,pr_cdmensagem    => null
                      ,pr_dsmensagem    => pr_dscritic
                      ,pr_idprglog      => vr_idprglog
                      ,pr_nmarqlog      => NULL);
    --      
    CECRED.pc_internal_exception( pr_cdcooper => 3 ,pr_compleme => pr_dscritic );
    --
  WHEN OTHERS THEN
    Rollback;
    -- Monta mensagem de erro
    pr_dscritic := 'Erro em pc_gera_conciliacao_spb: ' || SQLERRM;
    --
    CECRED.pc_log_programa(pr_dstiplog  => 'E'
                      ,pr_cdprograma    => 'SSBP0002'
                      ,pr_cdcooper      => 3
                      ,pr_tpexecucao    => 2 
                      ,pr_tpocorrencia  => 2
                      ,pr_cdcriticidade => 3
                      ,pr_cdmensagem    => null
                      ,pr_dsmensagem    => pr_dscritic
                      ,pr_idprglog      => vr_idprglog
                      ,pr_nmarqlog      => NULL);
    --                   
    CECRED.pc_internal_exception( pr_cdcooper => 3 
                                 ,pr_compleme => pr_dscritic );

END pc_gera_conciliacao_spb;



END SSPB0002;
/
