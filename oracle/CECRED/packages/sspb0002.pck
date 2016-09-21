CREATE OR REPLACE PACKAGE CECRED.SSPB0002 AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: SSPB0002
--    Autor   : Douglas Quisinski
--    Data    : Julho/2015                      Ultima Atualizacao:   /  /    
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da concilia��o de arquivos do SPB.
--
--    Alteracoes: 
--    
---------------------------------------------------------------------------------------------------------------

  /* Rotina para processar o arquivo de concilia��o de TED/TEC */
  PROCEDURE pc_proc_concilia_ted_tec(pr_dspartes   IN VARCHAR2           --> Partes => PJA(JDSPB / AYLLOS)
                                    ,pr_dsdopcao   IN VARCHAR2           --> Op��o => OT (Todos) / OI (Ind�cios de Duplicidade) 
                                    ,pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                                    ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo

  /* Rotina para paginar as criticas da concilia��o de TED/TEC */
  PROCEDURE pc_paginar_criticas(pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo
                               ,pr_nrinicri   IN INTEGER            --> Numero da critica Inicial
                               ,pr_nrqtdcri   IN INTEGER            --> Quantidade de Criticas para paginar
                               ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                               ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
                               ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo



END SSPB0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SSPB0002 AS
---------------------------------------------------------------------------------------------------------------
--
--    Programa: SSPB0002
--    Autor   : Douglas Quisinski
--    Data    : Julho/2015                      Ultima Atualizacao: 22/04/2016
--
--    Dados referentes ao programa:
--
--    Objetivo  : BO ref. a Mensageria da concilia��o de arquivos do SPB.
--
--    Alteracoes: 22/04/2016 - Ajustado o nome do diretorio de upload do arquivo e 
--                             a query de busca na gnmvspb (Douglas - Melhoria 085)
--    
---------------------------------------------------------------------------------------------------------------
  -- Tipo de registro para conter as informa��es das linhas do arquivo
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
                                    ,pr_dsdopcao IN     VARCHAR2      --> Op��o => OT (Todos) / OI (Ind�cios de Duplicidade) 
                                    ,pr_tbcritic IN OUT typ_tbcritica --> Tabela de criticas encontradas na valida��o do arquivo
                                    ,pr_cdcritic    OUT PLS_INTEGER   --> C�digo da cr�tica
                                    ,pr_dscritic    OUT VARCHAR2) IS  --> Descri��o da cr�tica
  BEGIN
    /* .............................................................................
    Programa: pc_proc_arq_jdspb_ayllos
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 04/08/2015                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para processar o arquivo de concilia��o entre JDSPB/AYLLOS

    Especifica��o dos campos do arquivo de concilia��o entre JDSPB/AYLLOS (separados por ";"):
        - Grupo
        - Data Mensagem
        - Hora Mensagem
        - Hora Efetiva��o
        - �rea Neg.
        - Mensagem
        - N� Msg
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
        - C�d. Ident. Transf
        - Finalidade Cliente
        - Situa��o Msg
        - Num. Ctrl PAG/STR
        - Devolu��o da Transfer�ncia
        - Nr. Op
          
    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro  EXCEPTION;
      
      -- Vari�veis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Vari�veis para ler arquivo
      vr_dsdlinha VARCHAR2(32726);
      vr_utlfileh UTL_FILE.file_type;
      vr_des_erro crapcri.dscritic%TYPE;

      vr_arr_concil  gene0002.typ_split;
      
      -- Identifica��o da Transa��o
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
      -- Dados da Transa��o
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

      -- Campos para cria��o das criticas
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
      
      
      -- Cursor para identificar a Cooperativa/Ag�ncia
      CURSOR cr_crapcop IS
        SELECT crapcop.cdcooper,
               crapcop.cdagectl
          FROM crapcop;
      
      -- Cursor para identificar o log da mensagem de tansa��o do SPB
      CURSOR cr_craplmt(pr_dttransa IN craplmt.dttransa%TYPE) IS
        SELECT lmt.dttransa,
               lmt.hrtransa,
               lmt.nmevento,
               lmt.nrctrlif,
               lmt.vldocmto,
               -- Origem do lan�amento
               DECODE(lmt.idorigem,1,'AYLLOS CARACTER',
                                   2,'CAIXA ONLINE',
                                   3,'INTERNET BANK',
                                   4,'TAA',
                                   5,'AYLLOS WEB',
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
         WHERE lmt.cdcooper > 0
           AND lmt.nrdconta > 0
           AND lmt.nrsequen > 0         
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
         WHERE lmt.cdcooper > 0
           AND lmt.nrctrlif = pr_nrctrlif;
      vr_qtd_lmt INTEGER;
      
      -- Cursor para buscar as informa��es de Teansferencia de Cr�dito para a JD
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
                                'STR0006','STR0006R2','STR0025','PAG0121')
           AND spb.dtmensag = pr_dtmensag;
      rw_gnmvspb cr_gnmvspb%ROWTYPE;
           
      -- Cursor para buscar as informa��es do banco
      CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
        SELECT crapban.nrispbif
          FROM crapban
         WHERE crapban.cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;
      
      -- Cursor para buscar as informa��es do banco - pelo n�mero do ISPB
      CURSOR cr_crapban2 IS
        SELECT crapban.cdbccxlt
              ,crapban.nrispbif 
          FROM crapban 
         WHERE crapban.cdbccxlt > 0 
           AND crapban.nrispbif > 0;
           
      -- Registro de Cooperativas/Ag�ncia
      TYPE typ_tbagenci_coop IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
      vr_tbagenci_coop typ_tbagenci_coop;
      -- Registros de Bancos/ISPB
      TYPE typ_tbbanco_ispb  IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
      vr_tbbanco_ispb typ_tbbanco_ispb;
      -- Registro de Datas que existem no arquivo
      TYPE typ_dtdatas IS TABLE OF DATE INDEX BY VARCHAR2(10);
      vr_tbdatas typ_dtdatas;
      
      /* Fun��o para remover a mascara dos campos */
      FUNCTION fn_remove_mask(pr_valor IN VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        -- Utilizar mascara padr�o de conta de Nro Contrato
        RETURN REPLACE(REPLACE(REPLACE(pr_valor,'.',''),'-',''),'/','');
      END;
      
    BEGIN
      
      -- Limpar as tabelas
      pr_tbcritic.DELETE;  
      vr_tbprocessados.DELETE;
      vr_tbbanco_ispb.DELETE;
      vr_tbagenci_coop.DELETE;
      
      -- Carregar o c�digo das cooperativas, vinculadas para cada agencia
      vr_tbagenci_coop(0):= 0;
      FOR rw_crapcop IN cr_crapcop LOOP
        vr_tbagenci_coop(rw_crapcop.cdagectl):= rw_crapcop.cdcooper;
      END LOOP;
      
      -- Carregar o c�digo dos bancos vinculados para cada ISPB
      vr_tbbanco_ispb(0):= 1; -- ISPB zero � para o Banco do Brasil
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
          -- Limpa a vari�vel que receber� a linha do arquivo
          vr_dsdlinha := NULL;
          vr_nrdlinha := vr_nrdlinha + 1;
          BEGIN         
            -- L� a linha do arquivo
            GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh
                                        ,pr_des_text => vr_dsdlinha);
            
            -- Eliminar poss�veis espa�os das linhas
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
            
            -- Criando um array com todas as informa��es da concili��o
            vr_arr_concil := gene0002.fn_quebra_string(vr_dsdlinha, ';');
            
            --Validar se o primeiro campo � o cabe�alho do arquivo
            IF UPPER(vr_arr_concil(1)) = 'GRUPO' THEN
              CONTINUE;
            END IF;
            
            -- Validar se a informacao do grupo veio
            IF TRIM(vr_arr_concil(1)) IS NULL THEN
              CONTINUE;
            END IF;

            -- Carregar a mensagem que esta sendo processada
            vr_dsmensag := TRIM(vr_arr_concil(6));
            
            -- Solicita��o da �rea do SPB
            -- Desconsiderar tipo de mensagem STR0004 e STR0004R2, pois s�o mensagens que n�o afetam cliente
            -- Desconsiderar tipo de mensagem STR0003 e STR0003R2, pois s�o mensagens que n�o afetam cliente
            -- Desconsiderar tipo de mensagem STR0007, pois s�o mensagens que n�o afeta cliente (manter a STR0007R2, pois essa afeta)
            IF vr_dsmensag IN ('STR0004','STR0004R2','STR0003','STR0003R2','STR0007') OR
               vr_dsmensag IS NULL THEN
              CONTINUE;
            END IF;
            
            -- Nao conciliar devolu��es remetidas, 
            -- apenas alertar qual credito esta efetivado e nao creditou a conta, 
            -- pois neste caso significa que houve problema neste tipo de mensagem
            IF vr_dsmensag IN('STR0010','PAG0111') THEN 
              -- Ignorar essas mensagens (Karoline - SPB)
              CONTINUE;
            END IF;
            
            -- Conforme alinhado com o Diego, as mensagens de Portabilidade 
            -- STR0047, STR0047R1, STR0048 nao devem ser tratadas
            -- Apenas a mensagem de recebimento da STR00047R2 deve ser validada
            IF vr_dsmensag IN ('STR0047R1','STR0048') THEN
              CONTINUE;
            END IF;
            
            -- Desmontar a linha de acordo com o layout do arquivo (Os campos em branco/zeros ser�o ignorados
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
            -- Dados da Transa��o
            vr_vlconcil  := TO_NUMBER(TRIM(vr_arr_concil(23)),'FM9G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.');
            vr_vlconsul  := ABS(vr_vlconcil);
            vr_dssitmen  := TRIM(vr_arr_concil(26));
            vr_nrcontro  := TRIM(vr_arr_concil(27));

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
            vr_index_proc:= 'ARQUIVO'                     || -- Identificacao Arquivo JD
                            TO_CHAR(vr_ispbif_deb)        || -- Banco Debitada
                            TO_CHAR(vr_cdagenci_deb)      || -- Agencia Debitada
                            TO_CHAR(vr_nrdconta_deb)      || -- Conta Debitada
                            TO_CHAR(vr_nrcpfcgc_deb_pesq) || -- CPF/CNPJ Debitado
                            TO_CHAR(vr_ispbif_cre)        || -- Banco Creditado
                            TO_CHAR(vr_cdagenci_cre)      || -- Agencia Creditada 
                            TO_CHAR(vr_nrdconta_cre)      || -- Conta Creditada
                            TO_CHAR(vr_nrcpfcgc_cre_pesq) || -- CPF/CNPJ Creditado
                            TO_CHAR(vr_vlconsul * 100);      -- Valor (MULTIPLICAR POR 100 PARA TIRAR DECIMAIS)
                             
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
              
              -- Zerar os identificadores de cria��o do  erro
              vr_cria_critica:= 0; --> Identifica a gera��o da Cr�tica
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
              -- Indice para identifica��o das criticas PADRAO
              vr_chave_conciliar:= TO_CHAR(vr_nrcontro)          || -- Numero de Controle
                                   TO_CHAR(vr_cdagenci_deb)      || -- Agencia Debitada
                                   TO_CHAR(vr_nrdconta_deb)      || -- Conta Debitada
                                   TO_CHAR(vr_nrcpfcgc_deb_pesq) || -- CPF/CNPJ Debitado
                                   TO_CHAR(vr_cdagenci_cre)      || -- Agencia Creditada 
                                   TO_CHAR(vr_nrdconta_cre)      || -- Conta Creditada
                                   TO_CHAR(vr_nrcpfcgc_cre_pesq) || -- CPF/CNPJ Creditado
                                   TO_CHAR(vr_vlconsul * 100);      -- Valor 
                              
              
              -- Verifica se a duplicidade existe
              IF vr_dsduplic = 'S' THEN
                -- Se o registro j� foi adicionado como erro
                -- Apenas atualiza a situa��o para duplicado, e processa a pr�xima linha
                IF pr_tbcritic.EXISTS(vr_chave_conciliar) THEN
                  -- Duplicado 
                  pr_tbcritic(vr_chave_conciliar).dsduplic:= 'S';
                  -- Passa para a proxima linha
                  CONTINUE;
                END IF;
              END IF;
              
              -- Zerar os identificadores de cria��o do  erro
              vr_cria_critica:= 0; --> Identifica a gera��o da Cr�tica
              vr_conciliar   := 1; --> Identifica se a linha deve ser armazenada para conciliar
              
              -- Criticar qualquer mensagem recebida com esta nomenclatura, independente de status. 
              -- Ayllos n�o realiza o cr�dito desta TED automaticamente
              IF vr_dsmensag IN ('STR0025R2','STR0029R2','STR0034R2','STR0040R2',
                                 'PAG0121R2','PAG0134R2','PAG0142R2') THEN
                -- Sempre gerar cr�tica
                vr_cria_critica := 1;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
              
              -- N�o enviamos, n�o ser� necess�rio tratamento. 
              -- Portanto, qualquer lan�amento com esta nomenclatura, 
              -- independente de status, criticar em relat�rio!
              ELSIF vr_dsmensag IN('STR0029','STR0034','STR0040','STR0048',
                                   'PAG0134','PAG0143') THEN 
                -- Sempre gerar cr�tica
                vr_cria_critica := 1;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
                
              -- Como sistema n�o tem como validar envios de portabilidade que s�o efetivados apenas no CTC, 
              -- criticar qualquer mensagem com esta nomenclatura, indiferente de status.
              ELSIF vr_dsmensag IN('STR0048R2') THEN 
                -- Sempre gerar cr�tica
                vr_cria_critica := 1;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
                
              -- Mensagem � enviada atrav�s do Caixa Online. 
              -- Conciliar lan�amento JD com lan�amento em esp�cie (n�o movimenta conta corrente). 
              -- Apontar diferen�a se status "devolvido", "rejeitado Bacen", "rejeitado CIP".
              ELSIF vr_dsmensag IN('STR0005','PAG0107') THEN 
                IF UPPER(vr_dssitmen) LIKE UPPER('%REJEITADO%') OR
                   UPPER(vr_dssitmen) LIKE UPPER('%DEVOLVIDO%') THEN
                  -- Gerar cr�cia pois o lan�amento em esp�cie foi devolvido/rejeitado
                  vr_cria_critica := 1;           
                END IF;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
                
              -- Mensagem eh enviada atraves do CTC e SPB da JD. 
              -- Portanto, qualquer lan�amento com esta nomenclatura, 
              -- SE status diferente de "efetivado", criticar em relatorio!
              ELSIF vr_dsmensag IN('STR0047') THEN 
                IF UPPER(vr_dssitmen) NOT LIKE UPPER('%EFETIVADO%') THEN
                  -- Gerar cr�cia pois o lan�amento em esp�cie foi devolvido/rejeitado
                  vr_cria_critica := 1;           
                END IF;
                -- Nao conciliar essa mensagem
                vr_conciliar    := 0;
                
              -- Sistema dever� identificar qual o n�mero de controle da TED original (TED origem efetivada)
              -- para validar qual a conta corrente a ser creditada a devolu��o.
              -- Validar os campos: IF, Valor e N�mero de Controle Original 
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
              -- Validar os campos: Ag�ncia, Conta Corrente, CPF/CNPJ e Valor
              ELSIF vr_dsmensag IN('STR0005R2','STR0007R2','STR0008R2',
                                   'PAG0107R2','PAG0108R2','PAG0143R2') THEN 
                
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_cre) || '_' || 
                                     TO_CHAR(vr_nrdconta_cre) || '_' ||
                                     TO_CHAR(vr_nrcpfcgc_cre_pesq) || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);


              -- Validar se a mensagem pertence ao VR BOLETO
              ELSIF vr_dsmensag IN('STR0026','PAG0122') THEN 

                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                -- Quando VR BOLETO, validar apenas se existe o registro na gnmvspb
                vr_chave_conciliar:= TO_CHAR(vr_tbagenci_coop(NVL(vr_cdagenci_deb,0))) || '_' || 
                                     TO_CHAR(vr_dsmensag) || '_' ||
                                     TO_CHAR(vr_dtmensag,'DDMMRRRR') || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);
            
              -- Validar se a mensagem pertence ao RETORNO de VR BOLETO
              ELSIF vr_dsmensag IN('STR0026R2','PAG0122R2') THEN 
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                -- Quando VR BOLETO, validar apenas se existe o registro na gnmvspb
                vr_chave_conciliar:= TO_CHAR(vr_tbagenci_coop(NVL(vr_cdagenci_cre,0))) || '_' || 
                                     TO_CHAR(vr_dsmensag) || '_' ||
                                     TO_CHAR(vr_dtmensag,'DDMMRRRR') || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);

              -- Sistema credita estes tipos de TED automaticamente. 
              -- Validar os campos: Ag�ncia, Conta Corrente, CPF/CNPJ (debitado) e Valor
              ELSIF vr_dsmensag IN('STR0037R2','PAG0137R2') THEN 
                      
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_cre) || '_' || 
                                     TO_CHAR(vr_nrdconta_cre) || '_' ||
                                     TO_CHAR(vr_nrcpfcgc_deb_pesq) || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);
              
              -- TED por esta finalidade n�o credita automaticamente a conta corrente. 
              -- Validar os campos: Ag�ncia, Conta Corrente, Valor
              ELSIF vr_dsmensag IN('STR0006') THEN 
                      
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_deb) || '_' || 
                                     TO_CHAR(vr_nrdconta_deb) || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);
              
              -- TED por esta finalidade n�o credita automaticamente a conta corrente. 
              -- Validar os campos: Ag�ncia, Conta Corrente, Valor
              ELSIF vr_dsmensag IN('STR0006R2') THEN 
                      
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_cre) || '_' || 
                                     TO_CHAR(vr_nrdconta_cre) || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);
                                     
              -- Mensagem � enviada atrav�s da Cabine JD.
              -- Validar os campos: Ag�ncia, Conta Corrente, Valor
              ELSIF vr_dsmensag IN('STR0025','PAG0121') THEN 
                      
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_deb) || '_' || 
                                     TO_CHAR(vr_nrdconta_deb) || '_' ||
                                     TO_CHAR(vr_vlconsul * 100);

              -- Mensagem de Recebimento da Portabilidade
              -- Validar recebimento de cr�dito na JD com lan�amento de portabilidade no Ayllos 
              -- (tratamento diferente das TEDs). 
              -- Criticar caso n�o encontre lan�amento no sistema ou se status "devolvido"
              ELSIF vr_dsmensag IN('STR0047R2') THEN 
                
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                -- N�o validar o CPF/Agencia Debitados
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_nrdconta_deb) || '_' || -- Conta Debitada
                                     TO_CHAR(vr_cdagenci_cre) || '_' || -- Agencia Creditada
                                     TO_CHAR(vr_nrdconta_cre) || '_' || -- Conta Creditada
                                     TO_CHAR(vr_nrcpfcgc_cre_pesq) || '_' || -- CPF/CNPJ Creditado
                                     TO_CHAR(vr_ispbif_deb) || '_' || -- ISPB IF Debitada
                                     TO_CHAR(vr_vlconsul * 100); -- Valor do Documento
                
              -- Mensagem eh enviada atraves da internet, mobile e caixa online. 
              -- Conciliar lan�amento JD com lan�amento em especie/conta corrente/LOGSPB. 
              -- Validar status!
              ELSIF vr_dsmensag IN('STR0008','PAG0108') THEN 
                -- Conciliar essa mensagem
                vr_conciliar    := 1;
                -- Montar a chave de acordo com os campos que sao comparados para conciliar
                -- N�o validar o CPF/Agencia Debitados
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
                -- Validar os campos: Ag�ncia, Conta Corrente, CPF/CNPJ e Valor
                vr_chave_conciliar:= vr_dsmensag || '_' ||
                                     TO_CHAR(vr_cdagenci_deb) || '_' || -- Agencia Debitada
                                     TO_CHAR(vr_nrdconta_deb) || '_' || -- Conta Debitada
                                     TO_CHAR(vr_nrcpfcgc_deb_pesq) || '_' || -- CPF/CNPJ Debitado
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
              -- Acabou a leitura, ent�o finaliza o loop
              EXIT;
          END;
          
        END LOOP; -- Finaliza o loop das linhas do arquivo
        
        -- Fechar o arquivo
        GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
      END IF;

      -- Se n�o houverem dados no registro de mem�ria
      IF vr_tbarquivo.COUNT() = 0 AND vr_tbprocessados.COUNT() = 0 THEN
        vr_dscritic := GENE0007.fn_convert_db_web('Dados n�o encontrados no arquivo.');
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
          -- Validar os campos: Ag�ncia, Conta Corrente, CPF/CNPJ e Valor
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


          -- Mensagem � enviada atrav�s do Caixa Online. 
          -- Conciliar lan�amento JD com lan�amento em esp�cie (n�o movimenta conta corrente). 
          -- Apontar diferen�a se status "devolvido", "rejeitado Bacen", "rejeitado CIP".
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
          -- Validar os campos: Ag�ncia, Conta Corrente, CPF/CNPJ (debitado) e Valor
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
          -- Validar recebimento de cr�dito na JD com lan�amento de portabilidade no Ayllos 
          -- (tratamento diferente das TEDs). 
          -- Criticar caso n�o encontre lan�amento no sistema ou se status "devolvido"
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
            -- N�o validar o CPF/Agencia Debitados
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
          -- Conciliar lan�amento JD com lan�amento em especie/conta corrente/LOGSPB. 
          -- Validar status!
          ELSIF vr_dsmensag IN('STR0008','PAG0108') THEN 
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            -- N�o validar o CPF/Agencia Debitados
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
                
            -- Validar os campos: Ag�ncia, Conta Corrente, CPF/CNPJ e Valor
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
            
          END IF;
          
          -- Verificar se a opcao eh para listar apenas as duplicidades
          IF pr_dsdopcao = 'OI' THEN
            -- Para a duplicidade temos validar outros campos
            -- Indice das linhas que foram processadas
            vr_index_proc:= 'AYLLOS'                         || -- Identificacao AYLLOS
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
              vr_tbprocessados(vr_index_proc).dsorigemerro := 'AYLLOS';
            END IF;
              
            -- Zerar os identificadores de cria��o do  erro
            vr_cria_critica:= 0; --> Identifica a gera��o da Cr�tica
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
              pr_tbcritic(vr_chave_conciliar).dsorigemerro := 'AYLLOS';
              
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
            vr_tbayllos(vr_chave_conciliar).dsorigemerro := 'AYLLOS';
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
            vr_chave_conciliar:= TO_CHAR(rw_gnmvspb.cdcooper) || '_' || 
                                 TO_CHAR(rw_gnmvspb.dsmensag) || '_' ||
                                 TO_CHAR(rw_gnmvspb.dtmensag,'DDMMRRRR') || '_' ||
                                 TO_CHAR(rw_gnmvspb.vllanmto * 100);

          -- VR BOLETO recebido
          ELSIF rw_gnmvspb.dsmensag IN ('STR0026R2','PAG0122R2') THEN
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            -- Quando VR BOLETO, validar apenas se existe o registro na gnmvspb
            vr_chave_conciliar:= TO_CHAR(rw_gnmvspb.cdcooper) || '_' || 
                                 TO_CHAR(rw_gnmvspb.dsmensag) || '_' ||
                                 TO_CHAR(rw_gnmvspb.dtmensag,'DDMMRRRR') || '_' ||
                                 TO_CHAR(rw_gnmvspb.vllanmto * 100);

          -- TED por esta finalidade n�o credita automaticamente a conta corrente. 
          -- Validar os campos: Ag�ncia, Conta Corrente, Valor
          ELSIF rw_gnmvspb.dsmensag IN ('STR0006') THEN
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            vr_chave_conciliar:= rw_gnmvspb.dsmensag || '_' ||
                                 TO_CHAR(TRIM(rw_gnmvspb.cdagendb)) || '_' || 
                                 TO_CHAR(TRIM(rw_gnmvspb.dscntadb)) || '_' ||
                                 TO_CHAR(rw_gnmvspb.vllanmto * 100);
              
          -- TED por esta finalidade n�o credita automaticamente a conta corrente. 
          -- Validar os campos: Ag�ncia, Conta Corrente, Valor
          ELSIF rw_gnmvspb.dsmensag IN('STR0006R2') THEN 
            -- Montar a chave de acordo com os campos que sao comparados para conciliar
            vr_chave_conciliar:= rw_gnmvspb.dsmensag || '_' ||
                                 TO_CHAR(TRIM(rw_gnmvspb.cdagencr)) || '_' || 
                                 TO_CHAR(TRIM(rw_gnmvspb.dscntacr)) || '_' ||
                                 TO_CHAR(rw_gnmvspb.vllanmto * 100);
              
          -- Mensagem � enviada atrav�s da Cabine JD.
          -- Validar os campos: Ag�ncia, Conta Corrente, Valor
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
            vr_index_proc:= 'AYLLOS'                 || -- Identificacao AYLLOS
                            TO_CHAR(vr_ispbif_deb)   || -- Banco Debitada
                            TO_CHAR(vr_cdagenci_deb) || -- Agencia Debitada
                            TO_CHAR(vr_nrdconta_deb) || -- Conta Debitada
                            TO_CHAR(vr_nrcpfcgc_deb) || -- CPF/CNPJ Debitado
                            TO_CHAR(vr_ispbif_cre)   || -- Banco Creditado
                            TO_CHAR(vr_cdagenci_cre) || -- Agencia Creditada 
                            TO_CHAR(vr_nrdconta_cre) || -- Conta Creditada
                            TO_CHAR(vr_nrcpfcgc_cre) || -- CPF/CNPJ Creditado
                            TO_CHAR(vr_vlconsul * 100); -- Valor (MULTIPLICAR POR 100 PARA TIRAR DECIMAIS)
                             
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
              vr_tbprocessados(vr_index_proc).dsorigemerro := 'AYLLOS';
            END IF;
              
            -- Zerar os identificadores de cria��o do  erro
            vr_cria_critica:= 0; --> Identifica a gera��o da Cr�tica
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
              pr_tbcritic(vr_chave_conciliar).dsorigemerro := 'AYLLOS';
              
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
            vr_tbayllos(vr_chave_conciliar).dsorigemerro := 'AYLLOS';

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
          vr_dscritic:= dbms_utility.format_error_backtrace || ' - ' ||
                        dbms_utility.format_error_stack;
        END IF;
        
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro geral (SSPB0002.pc_proc_arq_jdspb_ayllos): ' || 
                       vr_dscritic;
    END;
  END pc_proc_arq_jdspb_ayllos;
      
  PROCEDURE pc_proc_concilia_ted_tec(pr_dspartes   IN VARCHAR2           --> Partes => PJA(JDSPB / AYLLOS)
                                    ,pr_dsdopcao   IN VARCHAR2           --> Op��o => OT (Todos) / OI (Ind�cios de Duplicidade) 
                                    ,pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo
                                    ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                                    ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
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
    Objetivo  : Rotina para validar as inconsistencias no arquivo de concilia��o de TED/TEC

    Alteracoes: 01/06/2016 - Ajustes na forma de recebimento do arquivo que esta sendo 
                             conciliado e na geracao do arquivo de criticas
                             (Douglas - Chamado 443701)
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro   EXCEPTION;
      vr_exc_inform EXCEPTION;
      
      -- Vari�veis de erro
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
      vr_tbcritic typ_tbcritica; -- Tabela de criticas encontradas na valida��o do arquivo
      
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

      -- Busca o diret�rio do upload do arquivo
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'M'
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'spb');
                                          
      -- Nome do arquivo possui apenas o nome sem a extens�o
      -- A extens�o por padr�o � csv
      vr_nmarquiv := pr_nmarquiv || '.csv';
                                          
      -- Verifica se o arquivo existe
      IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||vr_nmarquiv) THEN
        -- Retorno de erro
        vr_dscritic := GENE0007.fn_convert_db_web('Arquivo n�o encontrado. (' || 
                                                  vr_dsdireto||'/'||vr_nmarquiv || 
                                                  ')');
        pr_nmdcampo := 'nmarquiv';
        RAISE vr_exc_erro;
      END IF;
      
      -- Verificar quais s�o as partes 
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
          vr_dscritic := GENE0007.fn_convert_db_web('Par�metro PARTES inv�lido');
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
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto    --> Diret�rio do arquivo
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
      END LOOP; -- Loop das cr�ticas
      
      -- Fechar o arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);
      
      -- gerar a mensagem com a quantidade de criticas 
      RAISE vr_exc_inform;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
        
      WHEN vr_exc_inform THEN
        -- Retornar a quantidade de Criticas identificadas
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Inform>' || to_char(vr_qtcritic) || '</Inform></Root>');
        ROLLBACK;
        
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (SSPB0002.pc_proc_concilia_ted_tec): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_proc_concilia_ted_tec;

  /* Rotina para paginar as criticas da concilia��o de TED/TEC */
  PROCEDURE pc_paginar_criticas(pr_nmarquiv   IN VARCHAR2           --> Nome do arquivo
                               ,pr_nrinicri   IN INTEGER            --> Numero da critica Inicial
                               ,pr_nrqtdcri   IN INTEGER            --> Quantidade de Criticas para paginar
                               ,pr_xmllog     IN VARCHAR2           --> XML com informa��es de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER        --> C�digo da cr�tica
                               ,pr_dscritic  OUT VARCHAR2           --> Descri��o da cr�tica
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
    Objetivo  : Rotina para paginar as criticas da concilia��o de TED/TEC

    Alteracoes:
    ............................................................................. */
    DECLARE
      -- Exce��o
      vr_exc_erro    EXCEPTION;
      vr_exc_fim_qtd EXCEPTION;
      
      -- Vari�veis de erro
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

      -- Busca o diret�rio do upload do arquivo
      vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'M'
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => 'spb');
                                          
      -- Nome do arquivo possui apenas o nome sem a extens�o
      -- A extens�o por padr�o � csv
      vr_nmarquiv := pr_nmarquiv || '_criticas.csv';
                                          
      -- Verifica se o arquivo existe
      IF NOT GENE0001.fn_exis_arquivo(pr_caminho => vr_dsdireto||'/'||vr_nmarquiv) THEN
        -- Retorno de erro
        vr_dscritic := GENE0007.fn_convert_db_web('Arquivo de cr�ticas n�o encontrado. (' || 
                                                  vr_dsdireto||'/'||vr_nmarquiv || 
                                                  ')');
        pr_nmdcampo := 'nmarquiv';
        RAISE vr_exc_erro;
      END IF;

      -- Abrir o arquivo de criticas
      gene0001.pc_abre_arquivo (pr_nmdireto => vr_dsdireto  --> Diret�rio do arquivo
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
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral (SSPB0002.pc_paginar_criticas): ' || SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_paginar_criticas;

END SSPB0002;
/
