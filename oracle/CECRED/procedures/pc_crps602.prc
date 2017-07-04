CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS602(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Indicador de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE  --> Codigo do operador
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
BEGIN
  /* ...........................................................................
   Programa: PC_CRPS602    (Fontes/crps602.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andr? Santos - Supero
   Data    : JULHO/2011                      Ultima atualizacao: 04/07/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 82.
               Integrar arquivo de faturas BRADESCO CECRED
               Emite relatorio 603.

   Alteracoes: 08/09/2011 - Ajustes na importa??o e relat?rio (Irlan)

               14/12/2011 - Realizado a importacao do campo dsparcel (Adriano).

               17/09/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

               22/11/2013 - Correção na chamada a vr_exc_fimprg, a mesma só deve
                            ser acionada em caso de saída para continuação da cadeia,
                            e não em caso de problemas na execução (Marcos-Supero)

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

               27/06/2014 - Correcao da nomenclatura do arquivo de LOG (.err) 169763 - (Carlos Rafael Tanholi)
               
               07/04/2017 - #642531 Inclusão de trim no retorno do comando
                            "ls vr_nom_direto /bradesco/ vr_nmarqdeb  | wc -l" (Carlos)
                            
               04/07/2017 - Melhoria na busca dos arquivos que irão ser processador, conforme
                            solicitado no chamado 703589. (Kelvin)

............................................................................. */
  DECLARE
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS602';
    -- Tratamento de erros
    vr_exc_erro   exception;
    vr_exc_fimprg exception;
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    /* Cursor generico de calendario */
    RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;

    --Buscar associados da cooperativa
    CURSOR cr_crapass (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT nrdconta,
             nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper;

    -- Type para armazenar nome dos arquivos para processamento
    TYPE typ_tab_nmarqtel IS
      TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;

    --Vetor para armazenar os arquivos para processamento
    vr_vet_nmarqtel typ_tab_nmarqtel;

    --type para armazenar os totais
    TYPE typ_reg_total IS
       RECORD ( tot_qtcrdrjc NUMBER
               ,tot_vlnacrjc NUMBER
               ,tot_qtcrdrjd NUMBER
               ,tot_vlnacrjd NUMBER
               ,tot_qtcrdint NUMBER
               ,tot_vlnacint NUMBER
               ,tot_qtcrdrec NUMBER
               ,tot_vlnacrec NUMBER);

    --Definicao do tipo de registro para armazenar os totais
    TYPE typ_tab_total IS TABLE OF typ_reg_total INDEX BY PLS_INTEGER;
    vr_tab_total typ_tab_total;

    --type para os registros rejeitados
    TYPE typ_reg_wcraprej IS
       RECORD( cdcooper craprej.cdcooper%type
              ,nrdconta varchar2(20)
              ,nmtitula crapecv.nmtitcrd%type
              ,nrcrcard crawcrd.nrcrcard%type
              ,dtmvtopg craprej.dtmvtolt%type
              ,vlfatura craprej.vllanmto%type
              ,dscritic varchar2(500));

    --Definicao do tipo de registro para armazenar os registros rejeitados
    TYPE typ_tab_wcraprej IS TABLE OF typ_reg_wcraprej
                          INDEX BY varchar2(48); --coop(10)+ nrconta(10)+nrcrcard(25)+id(3)

    vr_tab_wcraprej typ_tab_wcraprej;

    -- Variaveis para manipulacao dos arquivos
    vr_nom_direto    varchar2(100);
    vr_nom_dirarq    varchar2(100);
    vr_nmarqdeb      varchar2(100);
    vr_nom_arquivo   varchar2(100);
    vr_nmarqimp      varchar2(100);
    vr_setlinha      varchar2(500);
    vr_input_file    UTL_FILE.file_type;

    -- variaveis para utilizacao de comando no OS
    vr_comando       varchar2(200);
    vr_typ_saida     varchar2(4);


    vr_contador      number;
    vr_flgrejei      BOOLEAN := FALSE;
    vr_flg_fimprg    NUMBER(1);
    vr_flg_erro      NUMBER(1);
    
    --Variaveis utilizadas para armazenar os dados extraido dos arquivos
    vr_vlemreal  NUMBER  := 0;
    vr_nmtitula  CRAPASS.NMPRIMTL%TYPE := '';
    vr_dtmvtopg  DATE;
    vr_dtvencto  DATE;
    vr_nrdconta  NUMBER;
    vr_nrctacri  VARCHAR2(20);
    vr_nrcrcard  NUMBER;
    vr_cdcooper  CRAPCOP.CDCOOPER%TYPE;
    vr_idseqinc  NUMBER;
    vr_vlfatura  NUMBER;
    vr_vllanmto  NUMBER;
    vr_dsestabe  VARCHAR2(50);
    vr_dsativid  VARCHAR2(5);
    vr_dsparcel  VARCHAR2(5);
    vr_dtcompra  DATE;
    vr_cdmoedtr  VARCHAR2(3);
    vr_vlcpaori  NUMBER;
    vr_vlcparea  NUMBER;
    vr_cdtransa  VARCHAR2(4);
    vr_dscidade  VARCHAR2(13);
    vr_dsestado  VARCHAR2(2);
    vr_tpatvcom  VARCHAR2(1);
    vr_dsatvcom  VARCHAR2(30);
    vr_indebcre  VARCHAR2(1);
    vr_dtmvtolt  DATE;
    vr_cdoperad  CRAPOPE.CDOPERAD%TYPE;
    vr_tpregist  VARCHAR2(1):= '';

    --Chave do array
    vr_deschave      varchar2(48);

    --Variaveis de Controle de Restart
    vr_nrctares  INTEGER:= 0;
    vr_inrestar  INTEGER:= 0;
    vr_dsrestar  crapres.dsrestar%TYPE;

    -- Variavel para armazenar as informacos em XML
    vr_des_xml       clob;

    -- Flag utilizada para controlar se exibe ou n?o a tag final dos rejeitados
    vr_flgtag        boolean;

    --Escrever no arquivo CLOB
    PROCEDURE pc_escreve_xml(pr_des_dados IN CLOB) IS
    BEGIN
      --Escrever no arquivo XML
      vr_des_xml := vr_des_xml||pr_des_dados;
    END;

    --Procedimento para buscar os arquivos a serem processados e valida-los
    PROCEDURE pc_consistearq (pr_contaarq   OUT NUMBER
                             ,pr_flg_erro   OUT NUMBER  
                             ,pr_flg_fimprg OUT NUMBER 
                             ,pr_dscritic   OUT VARCHAR2) is

      vr_qtregist NUMBER;
      vr_nrdconta VARCHAR2(15);
      vr_dtarquiv VARCHAR2(8);
      vr_flgerros BOOLEAN := FALSE;
      vr_extensao VARCHAR(4) := '';
      vr_conarqui NUMBER:= 0;  
      vr_listarq  VARCHAR2(2000);
      vr_des_erro VARCHAR2(4000);                                    
      vr_split    gene0002.typ_split := gene0002.typ_split();

    BEGIN

      --Inicializar variaveis
      vr_nmarqdeb := 'carfat.%.original%';
      vr_qtregist := 0;
      vr_nrdconta := '2656-0164666';
      pr_flg_erro := 0;
      pr_flg_fimprg := 0;

      
      gene0001.pc_lista_arquivos(pr_path     => vr_nom_direto || '/bradesco/' 
                                ,pr_pesq     => vr_nmarqdeb  
                                ,pr_listarq  => vr_listarq 
                                ,pr_des_erro => vr_des_erro);
                        
      --Ocorreu um erro no lista_arquivos
      IF TRIM(vr_des_erro) IS NOT NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := vr_des_erro;
        pr_flg_erro := 1;
        RETURN;
      END IF;  
      
      --Nao encontrou nenhuma arquivo para processar
      IF TRIM(vr_listarq) IS NULL THEN
        vr_cdcritic := 182;
        vr_dscritic := NULL;
        pr_flg_fimprg := 1;
        RETURN;
      END IF;  
      
      vr_split := gene0002.fn_quebra_string(pr_string  => vr_listarq
                                           ,pr_delimit => ',');
      
      IF vr_split.count = 0 THEN
        vr_cdcritic := 182;
        vr_dscritic := NULL;
        pr_flg_fimprg := 1;
        RETURN;
      END IF;
      
      FOR vr_conarqui IN vr_split.FIRST..vr_split.LAST LOOP
       
        vr_vet_nmarqtel(vr_conarqui) := vr_split(vr_conarqui);    
        
        pr_contaarq :=  vr_conarqui; 
        
        vr_nom_dirarq := vr_nom_direto || '/bradesco';
        
        -- Converte o arquivo de DOS para Unix
        gene0001.pc_oscommand_shell(pr_des_comando => 'dos2ux '||
                                    vr_nom_direto||'/'||vr_vet_nmarqtel(pr_contaarq)||
                                    vr_nom_direto||'/'||vr_vet_nmarqtel(pr_contaarq)||'.ux');

        -- Move o arquivo para "arquivo.ux"
        gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||
                                    vr_nom_direto||'/'||vr_vet_nmarqtel(pr_contaarq)||'.ux'||
                                    ' ' ||vr_nom_direto||'/'||vr_vet_nmarqtel(pr_contaarq));
      END LOOP;     
      
      --Valida cada arquivo lido
      FOR idx IN 1..pr_contaarq LOOP
        --Abrir o arquivo lido e percorrer as linhas do mesmo
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_dirarq       --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_vet_nmarqtel(idx)--> Nome do arquivo
                                ,pr_tipabert => 'R'                 --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file       --> Handle do arquivo aberto
                                ,pr_des_erro => pr_dscritic);       --> Erro
        IF pr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        vr_flgerros := false;
        BEGIN
          -- Ler arquivo linha a linha
          LOOP
            IF  utl_file.IS_OPEN(vr_input_file) THEN
              -- Le os dados do arquivo e coloca na variavel vr_setlinha
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto lido
            END IF;

            -- Validar apenas linhas que serao importadas
            IF SUBSTR(vr_setlinha, 1, 1) <> '0' AND
               SUBSTR(vr_setlinha, 1, 1) <> '1' AND
               SUBSTR(vr_setlinha, 1, 1) <> '2' AND
               SUBSTR(vr_setlinha, 1, 1) <> '3' THEN
                CONTINUE;
            END IF;

            vr_qtregist := vr_qtregist + 1;

            IF SUBSTR(vr_setlinha, 1, 1) = '0'   THEN
              --Na linha de cabecalho do arquivo, localizar a data
              vr_dtarquiv := SUBSTR(vr_setlinha, 112, 8);
              IF TRIM(vr_dtarquiv) is null   THEN
                vr_dtarquiv := 'err';
                vr_cdcritic := 789; /*789 - Data invalida no arquivo*/
                vr_flgerros := true;
              END IF;

            ELSIF SUBSTR(vr_setlinha, 1, 1) = '2'   THEN
              -- Na linha de cabecalho da conta/cartao, localizar a nrconta
              IF instr(vr_setlinha, vr_nrdconta) = 0   THEN
                vr_cdcritic := 127; /*127 - Conta errada.*/
                vr_flgerros := true;
              END IF;

            ELSIF   SUBSTR(vr_setlinha, 1, 1) = '3'   THEN
              -- Na linha final do arquivo buscar a qtd total de registros
              IF To_number(SUBSTR(vr_setlinha, 56, 7)) <> (vr_qtregist)   THEN
                vr_cdcritic := 504; /*504 - Quantidade de registros errada.*/
                vr_flgerros := true;
              END IF;
            END IF;

            -- sair caso exista erro
            IF vr_flgerros THEN
              exit;
            END IF;

          END LOOP; --Fim loop ler arquivo
        EXCEPTION
          WHEN utl_file.invalid_operation THEN
            --Nao conseguiu abrir o arquivo
            pr_dscritic:= 'Erro ao abrir o arquivo '||vr_vet_nmarqtel(idx)||' na rotina pc_crps602.';
            RAISE vr_exc_erro;
          WHEN no_data_found THEN
            -- Terminou de ler o arquivo
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
        END;

        IF vr_flgerros THEN
          IF vr_cdcritic > 0   THEN

            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || pr_dscritic || ' --> '
                                                     || vr_vet_nmarqtel(idx) );
            pr_dscritic := null;
            vr_cdcritic := null;
          END IF;

          --recupera a extensao do arquivo (.err)
          vr_extensao := SUBSTR(vr_vet_nmarqtel(idx), -4);
          --se ja houver .err no nome nao adiciona novamente
          IF  vr_extensao = '.err' THEN
              vr_extensao := '';
          ELSE --caso contrario adiciona .err
              vr_extensao := '.err';
          END IF;

          -- renomear arquivo para .err (dependendo da verificacao anterior)
          vr_comando:= 'mv '|| vr_nom_dirarq||'/'|| vr_vet_nmarqtel(idx)||' '
                            || vr_nom_dirarq||'/'|| vr_vet_nmarqtel(idx) || vr_extensao ||' 2> /dev/null';

          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_setlinha);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            RAISE vr_exc_erro;
          END IF;

          -- remover arquivo .q
          vr_comando:= 'rm '|| vr_nom_dirarq ||'/'|| vr_vet_nmarqtel(idx) ||'.q 2> /dev/null';

          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_setlinha);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            RAISE vr_exc_erro;
          END IF;

          vr_vet_nmarqtel(idx) := '';
          pr_contaarq          := pr_contaarq - 1;
          vr_flgerros          := FALSE;

        ELSE -- se nao encontrou erro
          -- criar uma copia acrescentando a data no nome
          vr_comando:= 'cp '|| vr_nom_dirarq ||'/'|| vr_vet_nmarqtel(idx)||' '
                            || vr_nom_dirarq ||'/'|| vr_vet_nmarqtel(idx)||'.'||
                            vr_dtarquiv||' 2> /dev/null';

          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_setlinha);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            RAISE vr_exc_erro;
          END IF;

        END IF;
        vr_qtregist := 0;

      END LOOP;
    EXCEPTION
      WHEN vr_exc_erro THEN
        NULL;
      WHEN OTHERS  THEN
        pr_dscritic := 'Erro ao consistir arquivo: '||SQLerrm;
    END pc_consistearq;

    -- Procedimento para validar linhas e grava-la, ou gerar registro de rejeitado para o relatorio
    PROCEDURE pc_gravalinha ( pr_cdcooper_arq IN out crapcop.cdcooper%type
                             ,pr_vlemreal     IN number
                             ,pr_nrcrcard     IN number
                             ,pr_nrdconta     IN number
                             ,pr_idx          IN number
                             ,pr_dtmvtopg     IN date
                             ,pr_dtvencto     IN date
                             ,pr_dtmvtolt     IN date
                             ,pr_dtcompra     IN date
                             ,pr_nrctacri     IN varchar2
                             ,pr_idseqinc     IN number
                             ,pr_dsparcel     IN crapecv.dsparcel%type
                             ,pr_nmtitula     IN crapecv.nmtitcrd%type
                             ,pr_indebcre     IN crapecv.indebcre%type
                             ,pr_dsatvcom     IN crapecv.dsatvcom%type
                             ,pr_tpatvcom     IN crapecv.tpatvcom%type
                             ,pr_dscidade     IN crapecv.nmcidade%type
                             ,pr_dsestado     IN crapecv.dsestabe%type
                             ,pr_dsestabe     IN crapecv.dsestabe%type
                             ,pr_vlcparea     IN crapecv.vlcparea%type
                             ,pr_vlcpaori     IN crapecv.vlcpaori%type
                             ,pr_cdtransa     IN crapecv.cdtransa%type
                             ,pr_cdmoedtr     IN crapecv.cdmoedtr%type
                             ,pr_dscritic     OUT varchar2
                             ) IS

      --Buscar cadastro de cartoes de credito
      CURSOR cr_crapcrd IS
        SELECT nrdconta
          FROM crapcrd
         WHERE crapcrd.cdcooper = pr_cdcooper
           AND crapcrd.nrcrcard = pr_nrcrcard;
      rw_crapcrd cr_crapcrd%rowtype;

      -- Buscar os extratos dos cartoes cecred visa.
      CURSOR cr_crapecv ( pr_cdcooper IN crapcop.cdcooper%type
                         ,pr_nrdconta IN craprej.nrdconta%type
                         ,pr_nrcrcard IN number
                         ,pr_dtvencto IN date
                         ,pr_idseqinc IN number
                         ) IS
        SELECT 1
          FROM crapecv e
         WHERE e.progress_recid =
                    (SELECT MIN(e1.progress_recid)--FIRST
                       FROM crapecv e1
                      WHERE e1.cdcooper = pr_cdcooper
                        AND e1.nrdconta = pr_nrdconta
                        AND e1.nrcrcard = pr_nrcrcard
                        AND e1.dtvencto = pr_dtvencto
                        AND e1.idseqinc = pr_idseqinc);
      rw_crapecv cr_crapecv%rowtype;

       --Buscar cadastro de cartoes de credito
      CURSOR cr_crapcrd_3 ( pr_cdcooper IN crapcop.cdcooper%type
                           ,pr_nrcrcard IN number) is
        SELECT nrdconta
          FROM crapcrd
         WHERE crapcrd.cdcooper = pr_cdcooper
           AND crapcrd.nrcrcard = pr_nrcrcard;
      rw_crapcrd_3 cr_crapcrd_3%rowtype;

      vr_regexist number := 0;
      vr_cdcritic number;
      vr_nrdcont2 crapcrd.nrdconta%type;
      vr_nrseqlan number :=0;
      vr_vlfatura number;

      --armazenar valor da variavel apos o inser na craprej
      vr_craprej_nrconta  number;
      vr_craprej_cdcritic number;

    BEGIN

      -- Se a cooperativa da linha for igual a que esta sendo utilizada para executar o processo,
      -- ir? fazer as validacoes e inserir na crapecv
      IF pr_cdcooper_arq = pr_cdcooper THEN
        vr_vlfatura := nvl(pr_vlemreal,0);

        --Validar cartao de credito
        OPEN cr_crapcrd;
        FETCH cr_crapcrd
         INTO rw_crapcrd;
        IF cr_crapcrd%NOTFOUND THEN
          vr_regexist := 0;--false
          close cr_crapcrd;
        ELSE
          vr_regexist := 1; --true
          close cr_crapcrd;
        END IF;

        IF pr_nrctacri IS NOT NULL THEN
          vr_cdcritic := 564; /* 564 - Conta nao cadastrada */
        ELSIF vr_regexist = 0 THEN
          vr_cdcritic := 546; /* 546 - Cartao nao encontrado */
        ELSE
          vr_cdcritic := 0;
        END IF;

        vr_nrseqlan := vr_nrseqlan + 1;

        -- Inserir registro no rejeitado
        BEGIN
          INSERT INTO craprej
                   ( cdagenci
                    ,dtrefere
                    ,dtmvtolt
                    ,nrdconta
                    ,dshistor
                    ,cdpesqbb
                    ,vlsdapli
                    ,vllanmto
                    ,nrdocmto
                    ,cdcooper
                    ,nrdctitg
                    ,cdcritic)
                 VALUES
                   ( nvl(pr_cdcooper_arq,0)     -- cdagenci
                    ,nvl(vr_cdprogra,' ')       -- dtrefere
                    ,pr_dtmvtopg                -- dtmvtolt
                    ,decode(vr_regexist,1,
                            nvl(rw_crapcrd.nrdconta,0),
                            nvl(pr_nrdconta,0)) --nrdconta
                    ,nvl(vr_nmtitula,' ')       -- dshistor
                    ,gene0002.fn_mask(vr_nrcrcard,'9999.9999.9999.9999') --cdpesqbb
                    ,nvl(pr_vlemreal,0)         -- vlsdapli
                    ,nvl(vr_vlfatura,0)         -- vllanmto
                    ,nvl(vr_nrseqlan,0)         -- nrdocmto
                    ,nvl(pr_cdcooper,0)         -- cdcooper
                    ,nvl(pr_nrctacri,' ')       -- nrdctitg
                    ,nvl(vr_cdcritic,0))        -- cdcritic
           returning nrdconta,
                     cdcritic
                into vr_craprej_nrconta,
                     vr_craprej_cdcritic;
        EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro ao inserir rejeitado:'||SQLerrm;
            RAISE vr_exc_erro;
        END;

        -- Verificar se existe extratos dos cartoes cecred visa.
        OPEN cr_crapecv( pr_cdcooper => pr_cdcooper_arq
                        ,pr_nrdconta => vr_craprej_nrconta
                        ,pr_nrcrcard => pr_nrcrcard
                        ,pr_dtvencto => pr_dtvencto
                        ,pr_idseqinc => pr_idseqinc
                         );
        FETCH cr_crapecv
         INTO rw_crapecv;
        IF cr_crapecv%NOTFOUND THEN
          -- INSERIR extrato do cartao cecred visa.
          BEGIN
            INSERT INTO crapecv
                     ( cdcooper
                      ,nrdconta
                      ,nrcrcard
                      ,dtvencto
                      ,dtcompra
                      ,cdmoedtr
                      ,cdtransa
                      ,vlcpaori
                      ,vlcparea
                      ,nmcidade
                      ,cdufende
                      ,dsestabe
                      ,tpatvcom
                      ,dsatvcom
                      ,indebcre
                      ,dtmvtolt
                      ,cdoperad
                      ,idseqinc
                      ,nmarqimp
                      ,cdcritic
                      ,nmtitcrd
                      ,dsparcel )
                   VALUES
                     ( nvl(pr_cdcooper_arq,0)      -- cdcooper
                      ,nvl(vr_craprej_nrconta,0)   -- nrdconta
                      ,nvl(pr_nrcrcard,0)          -- nrcrcard
                      ,pr_dtvencto                 -- dtvencto
                      ,pr_dtcompra                 -- dtcompra
                      ,nvl(pr_cdmoedtr,' ')        -- cdmoedtr
                      ,nvl(pr_cdtransa,' ')        -- cdtransa
                      ,nvl(pr_vlcpaori,0)          -- vlcpaori
                      ,nvl(pr_vlcparea,0)          -- vlcparea
                      ,nvl(pr_dscidade,' ')        -- nmcidade
                      ,nvl(pr_dsestado,' ')        -- cdufende
                      ,nvl(pr_dsestabe,' ')        -- dsestabe
                      ,nvl(pr_tpatvcom,' ')        -- tpatvcom
                      ,nvl(pr_dsatvcom,' ')        -- dsatvcom
                      ,nvl(pr_indebcre,' ')        -- indebcre
                      ,pr_dtmvtolt                 -- dtmvtolt
                      ,nvl(pr_cdoperad,' ')        -- cdoperad
                      ,nvl(pr_idseqinc,0)          -- idseqinc
                      ,nvl(vr_vet_nmarqtel(pr_idx),' ')-- nmarqimp
                      ,nvl(vr_craprej_cdcritic,0)  -- cdcritic
                      ,nvl(pr_nmtitula,' ')        -- nmtitcrd
                      ,nvl(pr_dsparcel,' ')        -- dsparcel
                     );
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao inserir extrato(crapecv): '||SQLerrm;
              close cr_crapecv;
              RAISE vr_exc_erro;
          END;
          close cr_crapecv;
        ELSE
          -- somente fechar cursor
          close cr_crapecv;
        END IF;
      END IF;

      -- se for diferente de Cecred deve retornar
      IF pr_cdcooper <> 3 or
        pr_cdcooper_arq is null THEN
        RETURN;
      END IF;

      /* So pra CECRED ...*/
      vr_vlfatura := nvl(pr_vlemreal,0);

      -- Vericar se cart?o esta cadastrado
      OPEN cr_crapcrd_3( pr_cdcooper => pr_cdcooper_arq
                        ,pr_nrcrcard => pr_nrcrcard);
      FETCH cr_crapcrd_3
       INTO rw_crapcrd_3;
      IF cr_crapcrd_3%NOTFOUND THEN
        vr_regexist := 0;--false
        vr_nrdcont2 := pr_nrdconta;
        close cr_crapcrd_3;
      ELSE
        vr_regexist := 1; --true
        vr_nrdcont2 := rw_crapcrd_3.nrdconta;
        close cr_crapcrd_3;
      END IF;

      IF pr_cdcooper_arq <= 0 OR
         pr_cdcooper_arq >  gene0005.fn_ultima_cdcooper  THEN  /**Coop. Invalida**/

        IF pr_vlemreal < 0 THEN
          -- credito
          vr_tab_total(99).tot_qtcrdrjc := nvl(vr_tab_total(99).tot_qtcrdrjc,0) + 1;
          vr_tab_total(99).tot_vlnacrjc := nvl(vr_tab_total(99).tot_vlnacrjc,0) + nvl(pr_vlemreal,0);
        ELSE
          -- debito
          vr_tab_total(99).tot_qtcrdrjd := nvl(vr_tab_total(99).tot_qtcrdrjd,0) + 1;
          vr_tab_total(99).tot_vlnacrjd := nvl(vr_tab_total(99).tot_vlnacrjd,0) + nvl(pr_vlemreal,0);
        END IF;

        --(794 - Cooperativa Invalida)
        vr_cdcritic := 794;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        -- Armazenar rejeitados
        vr_deschave := lpad(pr_cdcooper_arq,10,0)||
                       lpad(pr_nrdconta,10,0)||
                       lpad(pr_nrcrcard,25,0)||
                       lpad(pr_idseqinc,3,0);

        vr_tab_wcraprej(vr_deschave).cdcooper := pr_cdcooper_arq;
        vr_tab_wcraprej(vr_deschave).nrdconta := pr_nrdconta;
        vr_tab_wcraprej(vr_deschave).nmtitula := pr_nmtitula;
        vr_tab_wcraprej(vr_deschave).nrcrcard := pr_nrcrcard ;
        vr_tab_wcraprej(vr_deschave).dtmvtopg := pr_dtmvtopg;
        vr_tab_wcraprej(vr_deschave).vlfatura := vr_vlfatura;
        vr_tab_wcraprej(vr_deschave).dscritic := pr_dscritic;
        pr_cdcooper_arq  := 99;



        -- Verificar se existe extratos dos cartoes cecred visa.
        OPEN cr_crapecv( pr_cdcooper => pr_cdcooper_arq
                        ,pr_nrdconta => vr_nrdcont2
                        ,pr_nrcrcard => pr_nrcrcard
                        ,pr_dtvencto => pr_dtvencto
                        ,pr_idseqinc => pr_idseqinc
                         );
        FETCH cr_crapecv
         INTO rw_crapecv;
        IF cr_crapecv%NOTFOUND THEN
          -- INSERIR extrato do cartao cecred visa.
          BEGIN
            INSERT INTO crapecv
                     ( cdcooper
                      ,nrdconta
                      ,nrcrcard
                      ,dtvencto
                      ,dtcompra
                      ,cdmoedtr
                      ,cdtransa
                      ,vlcpaori
                      ,vlcparea
                      ,nmcidade
                      ,cdufende
                      ,dsestabe
                      ,tpatvcom
                      ,dsatvcom
                      ,indebcre
                      ,dtmvtolt
                      ,cdoperad
                      ,idseqinc
                      ,nmarqimp
                      ,cdcritic
                      ,nmtitcrd
                      ,dsparcel )
                   VALUES
                     ( nvl(pr_cdcooper_arq,0)    -- cdcooper
                      ,nvl(vr_nrdcont2,0)        -- nrdconta
                      ,nvl(pr_nrcrcard,0)        -- nrcrcard
                      ,pr_dtvencto               -- dtvencto
                      ,pr_dtcompra               -- dtcompra
                      ,nvl(pr_cdmoedtr,' ')      -- cdmoedtr
                      ,nvl(pr_cdtransa,' ')      -- cdtransa
                      ,nvl(pr_vlcpaori,0)        -- vlcpaori
                      ,nvl(pr_vlcparea,0)        -- vlcparea
                      ,nvl(pr_dscidade,' ')      -- nmcidade
                      ,nvl(pr_dsestado,' ')      -- cdufende
                      ,nvl(pr_dsestabe,' ')      -- dsestabe
                      ,nvl(pr_tpatvcom,' ')      -- tpatvcom
                      ,nvl(pr_dsatvcom,' ')      -- dsatvcom
                      ,nvl(pr_indebcre,' ')      -- indebcre
                      ,pr_dtmvtolt               -- dtmvtolt
                      ,nvl(pr_cdoperad,' ')      -- cdoperad
                      ,nvl(pr_idseqinc,0)        -- idseqinc
                      ,nvl(vr_vet_nmarqtel(pr_idx),' ')-- nmarqimp
                      ,nvl(vr_cdcritic,0)        -- cdcritic
                      ,nvl(pr_nmtitula,' ')      -- nmtitcrd
                      ,nvl(pr_dsparcel,' ')      -- dsparcel
                     );
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao inserir extrato(crapecv): '||SQLerrm;
              close cr_crapecv;
              RAISE vr_exc_erro;
          END;
          close cr_crapecv;
        ELSE
          -- somente fechar cursor
          close cr_crapecv;
        END IF;

        pr_dscritic := null;

      ELSIF pr_nrcrcard = 0   OR
            vr_regexist = 0 THEN  /*ou cartao inv.*/

        IF vr_vlemreal < 0 THEN /* Credito */
          -- Caso ainda nao exista, somente iniciar
          IF vr_tab_total.EXISTS(pr_cdcooper_arq) THEN
            vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjc := nvl(vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjc,0) + 1;
            vr_tab_total(pr_cdcooper_arq).tot_vlnacrjc := nvl(vr_tab_total(pr_cdcooper_arq).tot_vlnacrjc,0) + pr_vlemreal;
          ELSE
            vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjc := 1;
            vr_tab_total(pr_cdcooper_arq).tot_vlnacrjc := nvl(pr_vlemreal,0);
          END IF;
        ELSE /* Debito */
          IF vr_tab_total.EXISTS(pr_cdcooper_arq) THEN
            vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjd := nvl(vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjd,0) + 1;
            vr_tab_total(pr_cdcooper_arq).tot_vlnacrjd := nvl(vr_tab_total(pr_cdcooper_arq).tot_vlnacrjd,0) + nvl(pr_vlemreal,0);
          ELSE
            vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjd := 1;
            vr_tab_total(pr_cdcooper_arq).tot_vlnacrjd := nvl(pr_vlemreal,0);

          END IF;

        END IF;

        --(546 - Cartao nao encontrado)
        vr_cdcritic := 546;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        -- Armazenar rejeitados
        vr_deschave := lpad(pr_cdcooper_arq,10,0)||
                       lpad(vr_nrdconta,10,0)||
                       lpad(pr_nrcrcard,25,0)||
                       lpad(pr_idseqinc,3,0);

        vr_tab_wcraprej(vr_deschave).cdcooper := pr_cdcooper_arq;
        vr_tab_wcraprej(vr_deschave).nrdconta := vr_nrdconta;
        vr_tab_wcraprej(vr_deschave).nmtitula := pr_nmtitula;
        vr_tab_wcraprej(vr_deschave).nrcrcard := pr_nrcrcard ;
        vr_tab_wcraprej(vr_deschave).dtmvtopg := pr_dtmvtopg;
        vr_tab_wcraprej(vr_deschave).vlfatura := vr_vlfatura;
        vr_tab_wcraprej(vr_deschave).dscritic := pr_dscritic;

        pr_dscritic := null;

      ELSIF trim(pr_nrctacri) is not null THEN

        IF nvl(pr_vlemreal,0) < 0 THEN /* Credito */
          -- Caso ainda nao exista, somente iniciar
          IF vr_tab_total.EXISTS(pr_cdcooper_arq) THEN
            vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjc := nvl(vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjc,0) + 1;
            vr_tab_total(pr_cdcooper_arq).tot_vlnacrjc := nvl(vr_tab_total(pr_cdcooper_arq).tot_vlnacrjc,0) + nvl(pr_vlemreal,0);
          ELSE
            vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjc := 1;
            vr_tab_total(pr_cdcooper_arq).tot_vlnacrjc := nvl(pr_vlemreal,0);
          END IF;
        ELSE /* Debito */
          -- Caso ainda nao exista, somente iniciar
          IF vr_tab_total.EXISTS(pr_cdcooper_arq) THEN
            vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjd := nvl(vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjd,0) + 1;
            vr_tab_total(pr_cdcooper_arq).tot_vlnacrjd := nvl(vr_tab_total(pr_cdcooper_arq).tot_vlnacrjd,0) + nvl(pr_vlemreal,0);
          ELSE
            vr_tab_total(pr_cdcooper_arq).tot_qtcrdrjd := 1;
            vr_tab_total(pr_cdcooper_arq).tot_vlnacrjd := nvl(pr_vlemreal,0);
          END IF;
        END IF;

        --(564 - Conta nao cadastrada.)
        vr_cdcritic := 564;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        -- Armazenar rejeitados
        vr_deschave := lpad(pr_cdcooper_arq,10,0)||
                       lpad(pr_nrctacri,10,0)||
                       lpad(pr_nrcrcard,25,0)||
                       lpad(pr_idseqinc,3,0);

        vr_tab_wcraprej(vr_deschave).cdcooper := pr_cdcooper_arq;
        vr_tab_wcraprej(vr_deschave).nrdconta := TRIM(pr_nrctacri);
        vr_tab_wcraprej(vr_deschave).nmtitula := pr_nmtitula;
        vr_tab_wcraprej(vr_deschave).nrcrcard := pr_nrcrcard ;
        vr_tab_wcraprej(vr_deschave).dtmvtopg := pr_dtmvtopg;
        vr_tab_wcraprej(vr_deschave).vlfatura := vr_vlfatura;
        vr_tab_wcraprej(vr_deschave).dscritic := pr_dscritic;

        pr_dscritic := null;

      ELSE -- Caso n?o entrar nos ifs de rejeitados, quardar valores como integrados
        -- Caso ainda nao exista, somente iniciar
        IF vr_tab_total.EXISTS(pr_cdcooper_arq) THEN
          vr_tab_total(pr_cdcooper_arq).tot_qtcrdint := nvl(vr_tab_total(pr_cdcooper_arq).tot_qtcrdint,0) + 1;
          vr_tab_total(pr_cdcooper_arq).tot_vlnacint := nvl(vr_tab_total(pr_cdcooper_arq).tot_vlnacint,0) + nvl(pr_vlemreal,0);

        ELSE
          vr_tab_total(pr_cdcooper_arq).tot_qtcrdint := 1;
          vr_tab_total(pr_cdcooper_arq).tot_vlnacint := nvl(pr_vlemreal,0);
        END IF;

      END IF;

      --Guardar valores recebidos
      -- Caso ainda nao exista, somente iniciar
      IF vr_tab_total.EXISTS(pr_cdcooper_arq) THEN
        vr_tab_total(pr_cdcooper_arq).tot_qtcrdrec := nvl(vr_tab_total(pr_cdcooper_arq).tot_qtcrdrec,0) + 1;
        vr_tab_total(pr_cdcooper_arq).tot_vlnacrec := nvl(vr_tab_total(pr_cdcooper_arq).tot_vlnacrec,0) + nvl(pr_vlemreal,0);
      ELSE
        vr_tab_total(pr_cdcooper_arq).tot_qtcrdrec := 1;
        vr_tab_total(pr_cdcooper_arq).tot_vlnacrec := nvl(pr_vlemreal,0);
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Execption tratada, apenas retornar
        NULL;
      WHEN OTHERS  THEN
        -- Erro nao tradado, adicionar erro oracle
        pr_dscritic := 'Erro ao gravar linha: '||SQLerrm;
    END pc_gravalinha;

    --Procedimento para adicionar no xml os registros rejeitados para o relatorio
    PROCEDURE pc_rejeitados IS

    BEGIN

      --Adicionar totais rejeitados
      vr_cdcooper := 99;
      pc_escreve_xml('<detcoope>
                        <nrdconta>** COOPERATIVA OU CARTAO INVALIDOS **</nrdconta>
                        <nmprimtl>999</nmprimtl>
                        <tot_qtcrdrec>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrec,0) ||'</tot_qtcrdrec>
                        <tot_qtcrdint>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdint,0) ||'</tot_qtcrdint>
                        <tot_qtcrdrjd>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrjd,0) ||'</tot_qtcrdrjd>
                        <tot_qtcrdrjc>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrjc,0) ||'</tot_qtcrdrjc>
                        <tot_vlnacrec>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacrec,0) ||'</tot_vlnacrec>
                        <tot_vlnacint>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacint,0) ||'</tot_vlnacint>
                        <tot_vlnacrjd>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacrjd,0) ||'</tot_vlnacrjd>
                        <tot_vlnacrjc>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacrjc,0) ||'</tot_vlnacrjc>
                      </detcoope>'
                     );

      pc_escreve_xml('</cooperado>');

      pc_escreve_xml('<Rejeitados>');

      --Verificar se existe registros rejeitados
      IF vr_tab_wcraprej.COUNT > 0 THEN

        --Inicalizar variaveis
        vr_deschave := vr_tab_wcraprej.first;
        vr_cdcooper := 99999;
        vr_flgtag   := false;

        -- Rejeitados credito
        LOOP
          --Enquanto existir chaves
          EXIT WHEN vr_deschave IS NULL;
          --se o valor eh menor que zero eh creditos
          IF vr_tab_wcraprej(vr_deschave).vlfatura < 0 THEN
            --verificar se mudou a ccooperativa
            IF vr_cdcooper <> vr_tab_wcraprej(vr_deschave).cdcooper THEN
              -- senao for a primeira, deve fechar a tag
              IF vr_cdcooper <> 99999 THEN
                 --fechar tag do grupo
                 pc_escreve_xml('</coprej>');
              END IF;
              --inicializar tag do grupo
              pc_escreve_xml('<coprej tipo="C" >');
              vr_cdcooper := vr_tab_wcraprej(vr_deschave).cdcooper;
              vr_flgtag := true;
            END IF;
            -- Formatar conta, caso apresentar falha exibir sem formatacao
            BEGIN
              vr_nrctacri := gene0002.fn_mask_conta(vr_tab_wcraprej(vr_deschave).nrdconta);
            EXCEPTION
              WHEN OTHERS THEN
                vr_nrctacri := vr_tab_wcraprej(vr_deschave).nrdconta;
            END;
            --montar xml com as informacoes de rejeitados
            pc_escreve_xml('<detrej>
                              <cdcooper>'||vr_tab_wcraprej(vr_deschave).cdcooper ||'</cdcooper>
                              <nrdconta>'||vr_nrctacri                           ||'</nrdconta>
                              <nmtitula>'||vr_tab_wcraprej(vr_deschave).nmtitula ||'</nmtitula>
                              <nrcrcard>'||gene0002.fn_mask(vr_tab_wcraprej(vr_deschave).nrcrcard,'9999.9999.9999.9999') ||'</nrcrcard>
                              <dtmvtopg>'||vr_tab_wcraprej(vr_deschave).dtmvtopg ||'</dtmvtopg>
                              <vlfatura>'||vr_tab_wcraprej(vr_deschave).vlfatura ||'</vlfatura>
                              <dscritic>'||vr_tab_wcraprej(vr_deschave).dscritic ||'</dscritic>
                            </detrej>');

          END IF;
          vr_deschave := vr_tab_wcraprej.next(vr_deschave);
        END LOOP;
        -- caso inicailizou grupo deve fecha-lo
        IF vr_flgtag THEN
          pc_escreve_xml('</coprej>');
        END IF;

        --Inicializar variaveis
        vr_deschave := vr_tab_wcraprej.first;
        vr_cdcooper := 99999;
        vr_flgtag   := FALSE;
        -- Rejeitados debito
        LOOP
          -- sair quando nao tiver mais chaves
          EXIT WHEN vr_deschave IS NULL;
          --se o valor for maior que zero ? debito
          IF vr_tab_wcraprej(vr_deschave).vlfatura > 0 THEN
            --verificar se mudou a ccooperativa
            IF vr_cdcooper <> vr_tab_wcraprej(vr_deschave).cdcooper THEN
              -- senao for a primeira, deve fechar a tag
              IF vr_cdcooper <> 99999 THEN
                 -- Fechar tag do grupo
                 pc_escreve_xml('</coprej>');
              END IF;
              --Inicializar tag do grupo
              pc_escreve_xml('<coprej tipo="D">');
              vr_flgtag   := TRUE;
              vr_cdcooper := vr_tab_wcraprej(vr_deschave).cdcooper;
            END IF;
            -- Formatar conta, caso apresentar falha exibir sem formatacao
            BEGIN
              vr_nrctacri := gene0002.fn_mask_conta(vr_tab_wcraprej(vr_deschave).nrdconta);
            EXCEPTION
              WHEN OTHERS THEN
                vr_nrctacri := vr_tab_wcraprej(vr_deschave).nrdconta;
            END;
            -- montar xml com as informacoes de rejeitados
            pc_escreve_xml('<detrej>
                              <cdcooper>'||vr_tab_wcraprej(vr_deschave).cdcooper ||'</cdcooper>
                              <nrdconta>'||vr_nrctacri                           ||'</nrdconta>
                              <nmtitula>'||vr_tab_wcraprej(vr_deschave).nmtitula ||'</nmtitula>
                              <nrcrcard>'||gene0002.fn_mask(vr_tab_wcraprej(vr_deschave).nrcrcard,'9999.9999.9999.9999') ||'</nrcrcard>
                              <dtmvtopg>'||vr_tab_wcraprej(vr_deschave).dtmvtopg ||'</dtmvtopg>
                              <vlfatura>'||vr_tab_wcraprej(vr_deschave).vlfatura ||'</vlfatura>
                              <dscritic>'||vr_tab_wcraprej(vr_deschave).dscritic ||'</dscritic>
                            </detrej>');

          END IF;
          vr_deschave := vr_tab_wcraprej.next(vr_deschave);
        END LOOP;
        --fechar tag do grupo, caso abriu
        IF vr_flgtag THEN
          pc_escreve_xml('</coprej>');
        END IF;

      END IF;
      -- fechar tag
      pc_escreve_xml('</Rejeitados>');
      --limpar tabela de memoria
      vr_tab_wcraprej.delete;
    END;


  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module =>  'PC_'||vr_cdprogra
                              ,pr_action => null);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;
    -- Leitura do calendario da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se nao encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1 --true
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro e <> 0
    IF vr_cdcritic <> 0 THEN
      -- Buscar descricao da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_erro;
    END IF;

    /* Tratamento e retorno de valores de restart */
    BTCH0001.pc_valida_restart(pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_flgresta => pr_flgresta
                              ,pr_nrctares => vr_nrctares
                              ,pr_dsrestar => vr_dsrestar
                              ,pr_inrestar => vr_inrestar
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_des_erro => vr_dscritic);
    --Se ocorreu erro na validacao do restart
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

    -- Busca do diretorio base da cooperativa
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null);

    -- Consistir arquivos a serem processados
    pc_consistearq(pr_contaarq   => vr_contador
                  ,pr_flg_erro   => vr_flg_erro 
                  ,pr_flg_fimprg => vr_flg_fimprg
                  ,pr_dscritic   => vr_dscritic);

    IF vr_dscritic is not null THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_erro;    
    END IF;
    
    IF vr_flg_erro = 1 THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_flg_fimprg = 1 THEN
      RAISE vr_exc_fimprg;
    END IF;

    --Ler todos os arquivos identificados pela pc_consistearq
    FOR idx IN 1..vr_contador LOOP

      -- iniicalizar variaveis
      vr_flgrejei := FALSE;
      vr_vlemreal := 0;
      vr_nmtitula := '';

      -- Varrer arquivo para buscar data de pagamento
      BEGIN
        --Abrir o arquivo lido e percorrer as linhas do mesmo
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_dirarq  --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_vet_nmarqtel(idx)    --> Nome do arquivo
                                ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);  --> Erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        -- Ler arquivo
        LOOP
          IF  utl_file.IS_OPEN(vr_input_file) THEN
            -- Le os dados do arquivo e coloca na variavel vr_setlinha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
          END IF;

          IF SUBSTR(vr_setlinha, 1, 1) = '0'   THEN
            vr_dtmvtopg := to_date(substr(vr_setlinha,112,8),'RRRRMMDD');
            vr_dtvencto := vr_dtmvtopg;
            EXIT;
          END IF;

        END LOOP; --Fim loop ler arquivo
      EXCEPTION
        WHEN utl_file.invalid_operation THEN
          --Nao conseguiu abrir o arquivo
          vr_dscritic:= 'Erro ao abrir o arquivo '||vr_vet_nmarqtel(idx)||' na rotina pc_crps602.';
          RAISE vr_exc_erro;
        WHEN no_data_found THEN
          -- Terminou de ler o arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
      END; --FIM Varrer arquivo para buscar data de pagamento

      IF vr_inrestar <> 0 AND vr_nrctares = 0 THEN
        BEGIN
          -- Deletar Cadastro de rejeitados na integracao - D23.
          DELETE craprej
           WHERE craprej.cdcooper = pr_cdcooper
             AND craprej.dtrefere = vr_cdprogra
             AND craprej.dtmvtolt = vr_dtmvtopg;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao deletar rejeitados: '||SQLErrm;
            RAISE vr_exc_erro;
        END;
      END IF;

      --Limpar e inicializar array
      vr_tpregist := '';
      vr_tab_total.delete;
      vr_tab_total(3 ).tot_qtcrdrec := 0;
      vr_tab_total(3 ).tot_vlnacrec := 0;
      vr_tab_total(99).tot_qtcrdrec := 0;
      vr_tab_total(99).tot_vlnacrec := 0;

      -- Continuar leitura do arquivo
      BEGIN
        LOOP
          IF  utl_file.IS_OPEN(vr_input_file) THEN
            -- Le os dados do arquivo e coloca na variavel vr_setlinha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
          END IF;

          --Buscar tipo do registro
          vr_tpregist := SUBSTR(vr_setlinha, 1, 1);

          IF (vr_tpregist = '3') THEN -- Se for final do registro
            IF pr_cdcooper = 3   THEN -- Cecred
              BEGIN
                INSERT INTO craprej
                       (dtrefere,
                        dtmvtolt,
                        nrdconta,
                        nrseqdig,
                        vldaviso,
                        vllanmto,
                        cdcritic,
                        cdcooper)
                       VALUES
                       (nvl(vr_cdprogra,' '),     -- dtrefere
                        vr_dtmvtopg,     -- dtmvtolt,
                        99999999,        -- nrdconta,
                        nvl(to_number(SUBSTR(vr_setlinha,42,7)),0),        -- nrseqdig,
                        nvl(to_number(SUBSTR(vr_setlinha,82,17)),0) / 100, -- vldaviso,
                        nvl(to_number(SUBSTR(vr_setlinha,64,17)),0) / 100, -- vllanmto,
                        1,               -- cdcritic,
                        pr_cdcooper);    -- cdcooper

              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic:= 'Erro ao inserir rejeitados: '||SQLErrm;
                  RAISE vr_exc_erro;
              END;
            END IF;

          ELSIF vr_tpregist = '0' THEN -- Se for cabecalho do arquivo

            vr_dtmvtopg := to_date(substr(vr_setlinha,112,8),'RRRRMMDD');
            vr_dtvencto := vr_dtmvtopg;
            IF vr_dtmvtopg <= rw_crapdat.dtmvtolt   THEN
              vr_dtmvtopg := rw_crapdat.dtmvtopr;
              continue;
            END IF;

          ELSIF vr_tpregist = '1' THEN -- se for cabecalho do cartao
            /* tratamento normal do tipo 1 */
            BEGIN
              BEGIN
                --Estrair nrdconta da string, retirar "." caso ja esteja formatado
                vr_nrdconta := to_number(replace(SUBSTR(vr_setlinha,261,15),'.'));
                vr_nrctacri := null;
              EXCEPTION
                WHEN OTHERS THEN
                  -- caso der erro ao converter para number, armazenar conta no conta critica
                  vr_nrctacri := SUBSTR(vr_setlinha,261,15);
                  vr_nrdconta := 0;
              END;

              --Buscar demais informacoes da linha
              vr_nrcrcard := to_number(SUBSTR(vr_setlinha,23,19));
              vr_nmtitula := SUBSTR(vr_setlinha,42,30);
              vr_cdcooper := to_number(nvl(TRIM(SUBSTR(vr_setlinha,187,12)),0));
              vr_idseqinc := 0;
              vr_vlemreal := 0;
              vr_vlfatura := 0;
              vr_vllanmto := 0;

            EXCEPTION
              -- Caso n?o conseguiu extrair alguma informacao da linha, levantar excecao
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao ler linha tpreg '||vr_tpregist||
                               ' nrcrcard '||vr_nrcrcard||': '||SQLerrm;
                RAISE vr_exc_erro;
            END;

          ELSIF vr_tpregist = '2' THEN --Linha dos lancamentos
            --somente se a cooperativa da linha for igual a cooperativa do processamento
            -- ou se o processamento ? para a cooperativa CECRED
            IF vr_cdcooper = pr_cdcooper OR
               pr_cdcooper = 3           THEN
              BEGIN

                IF SUBSTR(vr_setlinha, 113, 14) = 'SALDO ANTERIOR' THEN
                  --Ir para a proxima linha
                  continue;
                END IF;

                IF SUBSTR(vr_setlinha, 113, 18) = 'PAGAMENTO EFETUADO' THEN
                  --Ir para a proxima linha
                  continue;
                END IF;

                vr_idseqinc := vr_idseqinc + 1;
                vr_dsativid := SUBSTR(vr_setlinha,183,5);
                vr_dsestabe := SUBSTR(vr_setlinha,113,45);
                vr_dsparcel := '';
                vr_dtcompra := to_date(substr(vr_setlinha,46,8),'RRRRMMDD');
                vr_cdmoedtr := SUBSTR(vr_setlinha,219,3);

                BEGIN
                  -- armazenar valores conforme a moeda
                  IF TRIM(vr_cdmoedtr) = 'R$' THEN
                    vr_vlcpaori := 0;
                    vr_vlcparea := to_number(SUBSTR(vr_setlinha,59,13)) / 100;
                  ELSE
                    vr_vlcpaori := to_number(SUBSTR(vr_setlinha,59,13)) / 100;
                    vr_vlcparea := to_number(SUBSTR(vr_setlinha,236,13)) / 100;
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao buscar valores conforme a moeda: '||SQLErrm;
                    raise vr_exc_erro;
                END;

                vr_cdtransa := SUBSTR(vr_setlinha,42,4);
                vr_dscidade := SUBSTR(vr_setlinha,98,13);
                vr_dsestado := SUBSTR(vr_setlinha,111,2);
                vr_dsestabe := SUBSTR(vr_setlinha,113,45);
                vr_tpatvcom := SUBSTR(vr_setlinha,188,1);
                vr_dsatvcom := SUBSTR(vr_setlinha,189,30);
                vr_indebcre := SUBSTR(vr_setlinha,222,1);
                vr_dtmvtolt := rw_crapdat.dtmvtolt;
                vr_cdoperad := pr_cdoperad;
                vr_vllanmto := vr_vlcparea;

                IF SUBSTR(vr_setlinha,54,5) <> '00000' THEN
                  vr_dsparcel := SUBSTR(vr_setlinha,54,5);
                END IF;

                -- Se for credito os valores devem ser negativos
                IF upper(vr_indebcre) in ('C') THEN
                  vr_vllanmto := vr_vllanmto * -1;
                END IF;

                vr_vlemreal   := vr_vllanmto;
              EXCEPTION
                -- Caso n?o conseguiu extrair alguma informacao da linha, levantar excecao
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao ler linha tpreg '||vr_tpregist||
                                 ' nrcrcard '||vr_nrcrcard||': '||SQLerrm;
                  RAISE vr_exc_erro;
              END;
            END IF; -- Fim vr_cdcooper

            pc_gravalinha ( pr_cdcooper_arq => vr_cdcooper
                           ,pr_vlemreal     => vr_vlemreal
                           ,pr_nrcrcard     => vr_nrcrcard
                           ,pr_nrdconta     => vr_nrdconta
                           ,pr_idx          => idx
                           ,pr_dtmvtopg     => vr_dtmvtopg
                           ,pr_dtvencto     => vr_dtvencto
                           ,pr_dtmvtolt     => vr_dtmvtolt
                           ,pr_dtcompra     => vr_dtcompra
                           ,pr_nrctacri     => vr_nrctacri
                           ,pr_idseqinc     => vr_idseqinc
                           ,pr_dsparcel     => vr_dsparcel
                           ,pr_nmtitula     => vr_nmtitula
                           ,pr_indebcre     => vr_indebcre
                           ,pr_dsatvcom     => vr_dsatvcom
                           ,pr_tpatvcom     => vr_tpatvcom
                           ,pr_dscidade     => vr_dscidade
                           ,pr_dsestado     => vr_dsestado
                           ,pr_dsestabe     => vr_dsestabe
                           ,pr_vlcparea     => vr_vlcparea
                           ,pr_vlcpaori     => vr_vlcpaori
                           ,pr_cdtransa     => vr_cdtransa
                           ,pr_cdmoedtr     => vr_cdmoedtr
                           ,pr_dscritic     => vr_dscritic);

            IF vr_dscritic is not null THEN
              raise vr_exc_erro;
            END IF;

          END IF; -- Fim vr_tpregist

        END LOOP; --Fim loop ler arquivo
      EXCEPTION
        WHEN utl_file.invalid_operation THEN
          --Nao conseguiu abrir o arquivo
          vr_dscritic:= 'Erro ao abrir o arquivo '||vr_vet_nmarqtel(idx)||' na rotina pc_crps602.';
          RAISE vr_exc_erro;
        WHEN no_data_found THEN
          -- Terminou de ler o arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
      END; --FIM Ler arquivo

      IF pr_cdcooper = 3   THEN /* GERAR RELATORIO APENAS PARA COOP 3-CECRED */

        --buscar associados
        FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP
          --Identificar cooperativa atraves do numero da conta
          vr_cdcooper := gene0005.fn_cdcooper_nrctactl(pr_nrctactl => rw_crapass.nrdconta);

          --se retornar codigo da cooperativa e existir valores a serem somados
          IF vr_cdcooper > 0 AND
             vr_tab_total.EXISTS(vr_cdcooper) THEN

            -- Armazenar valores totais
            vr_tab_total(3).tot_qtcrdrec :=
                  nvl(vr_tab_total(3).tot_qtcrdrec,0) + nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrec,0);
            vr_tab_total(3).tot_vlnacrec :=
                  nvl(vr_tab_total(3).tot_vlnacrec,0) + nvl(vr_tab_total(vr_cdcooper).tot_vlnacrec,0);

            vr_tab_total(3).tot_qtcrdint :=
                  nvl(vr_tab_total(3).tot_qtcrdint,0) + nvl(vr_tab_total(vr_cdcooper).tot_qtcrdint,0);
            vr_tab_total(3).tot_vlnacint :=
                  nvl(vr_tab_total(3).tot_vlnacint,0) + nvl(vr_tab_total(vr_cdcooper).tot_vlnacint,0);

            vr_tab_total(3).tot_qtcrdrjd :=
                  nvl(vr_tab_total(3).tot_qtcrdrjd,0) + nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrjd,0);
            vr_tab_total(3).tot_vlnacrjd :=
                  nvl(vr_tab_total(3).tot_vlnacrjd,0) + nvl(vr_tab_total(vr_cdcooper).tot_vlnacrjd,0);

            vr_tab_total(3).tot_qtcrdrjc :=
                  nvl(vr_tab_total(3).tot_qtcrdrjc,0) + nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrjc,0);
            vr_tab_total(3).tot_vlnacrjc :=
                  nvl(vr_tab_total(3).tot_vlnacrjc,0) + nvl(vr_tab_total(vr_cdcooper).tot_vlnacrjc,0);

            IF vr_nrctares >= rw_crapass.nrdconta THEN
              continue;
            END IF;

          END IF;
        END LOOP;-- FIM loop crapass

        -- Gerar xml para o relatorio

        vr_nmarqimp    := 'crrl603_'|| lpad(idx,2,0);
        vr_cdcooper    := 3;

        -- Inicializar o CLOB
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

        --Inicializar xml
        pc_escreve_xml('<arquivo nmarquiv="'||vr_vet_nmarqtel(idx)||'" dtmvtopg="'||vr_dtmvtopg||'">');

        pc_escreve_xml('<cooperado>');
        --buscar associados
        FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper) LOOP
          --Identificar cooperativa atraves do numero da conta
          vr_cdcooper := gene0005.fn_cdcooper_nrctactl(pr_nrctactl => rw_crapass.nrdconta);

          --se existir valores a serem exibidos
          IF vr_tab_total.EXISTS(vr_cdcooper) THEN
            --Montar xml com os totais por cooperativa
            pc_escreve_xml('<detcoope>
                              <nrdconta>'||gene0002.fn_mask_conta(rw_crapass.nrdconta)||'</nrdconta>
                              <nmprimtl>'||rw_crapass.nmprimtl||'</nmprimtl>
                              <tot_qtcrdrec>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrec,0) ||'</tot_qtcrdrec>
                              <tot_qtcrdint>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdint,0) ||'</tot_qtcrdint>
                              <tot_qtcrdrjd>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrjd,0) ||'</tot_qtcrdrjd>
                              <tot_qtcrdrjc>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrjc,0) ||'</tot_qtcrdrjc>
                              <tot_vlnacrec>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacrec,0) ||'</tot_vlnacrec>
                              <tot_vlnacint>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacint,0)||'</tot_vlnacint>
                              <tot_vlnacrjd>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacrjd,0) ||'</tot_vlnacrjd>
                              <tot_vlnacrjc>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacrjc,0) ||'</tot_vlnacrjc>
                            </detcoope>'
                           );
          END IF;
        END LOOP;-- FIM loop crapass


        IF vr_cdcooper = 0 THEN
          --Montar totais gerais
          vr_cdcooper := 3;
          pc_escreve_xml('<detcoope>
                            <nrdconta> </nrdconta>
                            <nmprimtl>  ** TOTAL **</nmprimtl>
                            <tot_qtcrdrec>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrec,0) ||'</tot_qtcrdrec>
                            <tot_qtcrdint>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdint,0) ||'</tot_qtcrdint>
                            <tot_qtcrdrjd>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrjd,0) ||'</tot_qtcrdrjd>
                            <tot_qtcrdrjc>'||nvl(vr_tab_total(vr_cdcooper).tot_qtcrdrjc,0) ||'</tot_qtcrdrjc>
                            <tot_vlnacrec>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacrec,0) ||'</tot_vlnacrec>
                            <tot_vlnacint>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacint,0) ||'</tot_vlnacint>
                            <tot_vlnacrjd>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacrjd,0) ||'</tot_vlnacrjd>
                            <tot_vlnacrjc>'||nvl(vr_tab_total(vr_cdcooper).tot_vlnacrjc,0) ||'</tot_vlnacrjc>
                          </detcoope>'
                         );

        END IF;

        -- gerar adicionar ao xml os rejeitados
        pc_rejeitados;
        --Fechar tag principal
        pc_escreve_xml('</arquivo>');

        vr_des_xml  := '<?xml version="1.0" encoding="utf-8"?><crrl603>'||vr_des_xml||'</crrl603>';
        -- solicitar impressao
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/crrl603'          --> No base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl603.jasper'    --> Arquivo de layout do iReport
                                   ,pr_dsparams  => null  --> Enviar como parametro apenas a agencia
                                   ,pr_dsarqsaid => vr_nom_direto||'/rl/'||vr_nmarqimp||'.lst' --> Arquivo final com codigo da agencia
                                   ,pr_qtcoluna  => 132                 --> 132 colunas
                                   ,pr_flg_impri => 'S'                 --> Chamar a impressao (Imprim.p)
                                   ,pr_nmformul  => '132dh'             --> Nome do formulario para impress?o
                                   ,pr_nrcopias  => 1                   --> Numero de copias
                                   ,pr_des_erro  => vr_dscritic);       --> Saida com erro

        -- Liberando a memoria alocada pro CLOB
        dbms_lob.freetemporary(vr_des_xml);

        IF vr_dscritic IS NOT NULL THEN
          -- Gerar excecao
          raise vr_exc_erro;
        END IF;

      END IF;

      -- Comando para remover .q
      vr_comando:= 'rm '||vr_nom_dirarq ||'/'|| vr_vet_nmarqtel(idx) ||
                      '.q 2> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Comando para remover arq. original
      vr_comando:= 'rm '||vr_nom_dirarq||'/'||vr_vet_nmarqtel(idx) ||' 2> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Comando para mover arq. renomeado
      vr_comando:= 'mv '||vr_nom_dirarq ||'/'|| vr_vet_nmarqtel(idx) ||'* '
                        ||vr_nom_direto ||'/salvar/';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      IF vr_flgrejei THEN
        vr_cdcritic := 191;
      ELSE
        vr_cdcritic := 190;
      END IF;

      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic ||' --> '||vr_vet_nmarqtel(idx));

      vr_cdcritic := null;
      vr_dscritic := null;

      --Limpar registros rejeitados
      BEGIN
        DELETE craprej
         WHERE craprej.cdcooper = pr_cdcooper
           AND craprej.dtrefere = vr_cdprogra
           AND craprej.dtmvtolt = vr_dtmvtopg;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao deletar registros rejeitados(craprej): '||SQLerrm;
          RAISE vr_exc_erro;
      END;
    END LOOP;-- Lendo os arquivos pendentes

    /* Eliminacao dos registros de restart */
    BTCH0001.pc_elimina_restart(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_flgresta => pr_flgresta
                               ,pr_des_erro => vr_dscritic);
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;

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
      -- Se foi gerada critica para envio ao log
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit pois gravaremos o que foi processo até então
      COMMIT;
    WHEN vr_exc_erro THEN
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
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      -- Efetuar rollback
      ROLLBACK;
  END;
END;
/
