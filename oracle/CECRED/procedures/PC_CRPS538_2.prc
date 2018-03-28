CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS538_2(pr_flavaexe IN VARCHAR2                --> flag de avaliar a execução
                                               ,pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                               ,pr_nmtelant IN VARCHAR2                --> Nome tela anterior
                                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                               ,pr_dscritic OUT VARCHAR2               --> Descricao da Critica
                                               ) IS   
  BEGIN

  /* ................................................................................................

   Programa: PC_CRPS538_2                      Antigo: PC_CRPS538.PCK
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Belli / Envolti
   Data    : Agosto/2017.                   Ultima atualizacao: 11/08/2017
   
   Projeto:  Chamado 714566.

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo: 
     Foi retirada essas rotinas do programa cprs538 
     para priorizar as liberações do sistema para os clientes.
     - Gerar e enviar arquivo de retorno para o cooperado - PAG0001.pc_gera_arq_cooperado
     - Gerar Relatorio - pc_gera_relatorio_574 - INTEGRACAO DE DEVOLUCAO TITULOS - ABBC
     - Geração do arquivo de devolução - pc_gerar_arq_devolucao

   Alteracoes: 
       05/12/2017 - Inclusão de validação último dia mês, para buscar arquivos da pasta /win12/salvar/
                    Retirada da validação com a variável vr_dtleiarq
                    Ana - Envolti - Chamado 806333

       06/12/2017 - Ajustar data do arquivo de devolução para o próximo dia útil
                    quando a data do movimento for igual ao último dia do ano. (Rafael)

       06/12/2017 - Substituição do comando pc_set_modulo por pc_informa_acesso, para gerar as casas 
                    decimais corretamente

       07/12/2017 - Sustituir o tempo de espera do job de 30 minutos pela função fn_param_sistema
                    Ana - Envolti - Chamado 804921

       07/02/2018 - se o mês de dtmvtoan é diferente do mês de dtmvtolt então buscar arquivos
                    da pasta win12 - SD#842900 (AJFink)

   ................................................................................................*/

     DECLARE

       -- Selecionar lista de Cooperativas ativas
       CURSOR cr_crapcop_ativas  IS
         SELECT cop.cdcooper
         FROM crapcop cop
         WHERE cop.flgativo = 1
         ORDER BY cop.cdcooper;
       rw_crapcop_ativas cr_crapcop_ativas%ROWTYPE;

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
         SELECT cop.cdcooper
               ,cop.nmrescop
               ,cop.nrtelura
               ,cop.cdbcoctl
               ,cop.cdagectl
               ,cop.dsdircop
               ,cop.nrctactl
               ,cop.cdagedbb
               ,cop.cdageitg
         FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper
         AND   cop.flgativo = 1 ;
       rw_crapcop cr_crapcop%ROWTYPE;

       --Variaveis de Excecao
       vr_exc_final    EXCEPTION;
       vr_exc_saida    EXCEPTION;
       
       --Variaveis para retorno de erro
       vr_cdcritic     INTEGER        := NULL;
       vr_dscritic     VARCHAR2(4000) := NULL;                                                        
       
       -- Variavel para armazenar as informacoes em XML
       vr_des_xml      CLOB;
       vr_dstexto      VARCHAR2(32700);
	   
       --Constantes
       vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS538_2';

       --Variaveis Locais
       
       vr_fgferiado       BOOLEAN;
       vr_qtminutos       NUMBER(3);
       
       vr_nmarqimp        VARCHAR2(100);
       vr_flpdfcopi       VARCHAR2(1);
       vr_caminho_rl      VARCHAR2(1000);
       vr_caminho_rlnsv   VARCHAR2(1000);
       vr_nmarquiv        VARCHAR2(100);
       
       vr_qtdexec         INTEGER:= 0;   
	 
       -- Variavel pertencente a rotina PAGA0001.pc_gera_arq_cooperado
       vr_tab_arq_cobranca    PAGA0001.typ_tab_arq_cobranca;
       
       --Registro do tipo calendario
       rw_crapdat           BTCH0001.cr_crapdat%ROWTYPE;	       
       vr_inproces          crapdat.inproces%TYPE;       
       vr_dtmvtaux          crapdat.dtmvtoan%TYPE;       
       vr_dtmvtpro          crapdat.dtmvtolt%TYPE;

       -- Variáveis relacionadas ao processo de REPROC
       vr_inreproc          BOOLEAN;
       
       --Tabela para receber arquivos lidos no unix
       vr_tab_nmarqtel      GENE0002.typ_split;
       
       --Variaveis locais arquivo
       vr_setlinha           VARCHAR2(1000);
       vr_contador           INTEGER;
       vr_listadir           VARCHAR2(4000);
       vr_nmarqret           VARCHAR2(100);
       vr_caminho_puro       VARCHAR2(1000);
       vr_caminho_salvar     VARCHAR2(1000);
       vr_comando            VARCHAR2(1000);
       vr_typ_saida          VARCHAR2(1000);
       vr_dstipcob           VARCHAR2(6);
       vr_dtleiaux           VARCHAR2(8);
       vr_intemarq           BOOLEAN;
       vr_interminocoopers   NUMBER(1);
       
       -- Variaveis de controle de DBA SCHEDULER JOB LOG      
       vr_dsplsql         VARCHAR2(2000);
       vr_jobname         VARCHAR2(100);  

    -- Controla Controla log em banco de dados
    PROCEDURE pc_controla_log_programa(pr_dstiplog     IN VARCHAR2, -- Tipo de Log
                                       pr_tpocorrencia in number,   -- Tipo de ocorrencia
                                       pr_dscritic     IN VARCHAR2  -- Descrição do Log
                                      ,pr_cdcooperprog IN crapcop.cdcooper%TYPE DEFAULT pr_cdcooper   -- Codigo da cooperativa programada
                                      )
    IS
      vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    BEGIN         
      --> Controlar geração de log de execução dos jobs                                
      CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog, 
                             pr_cdprograma    => vr_cdprogra, 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 2, --job
                             pr_tpocorrencia  => pr_tpocorrencia,
                             pr_cdcriticidade => 0, --baixa
                             pr_dsmensagem    => pr_dscritic ||
                                                 ' - pr_flavaexe: ' || pr_flavaexe ||
                                                 ' ,pr_cdcooper: ' || pr_cdcooper ||
                                                 ' ,pr_nmtelant: ' || pr_nmtelant ||
                                                 ' ,pr_cdcooperprog: ' || pr_cdcooperprog,
                             pr_idprglog      => vr_idprglog);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END pc_controla_log_programa;

    --> Procedimento para geração do arquivo de devolução DVC605
    PROCEDURE pc_gerar_arq_devolucao(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                    ,pr_cdcritic  OUT INTEGER
                                    ,pr_dscritic  OUT VARCHAR2) IS
           
     ---------> CURSORES <---------
     --> Listar devoluoes da coop
     CURSOR cr_devolucao (pr_dtmvtolt crapdat.dtmvtolt%TYPE )IS
       SELECT ban2.nrispbif nrispbif_cop,
              cop.cdagectl,
              dev.dtocorre,
              dev.nrispbif,
              ban.cdbccxlt,
              dev.cdagerem,
              dev.dscodbar,
              dev.vlliquid,
              dev.cdmotdev,
              dev.tpcaptura,
              dev.tpdocmto,
              dev.nrseqarq,
              dev.dslinarq,
              row_number()        over (PARTITION BY cop.cdagectl 
                                        ORDER BY cop.cdagectl) nrseqrec,
              COUNT(dev.cdcooper) over (PARTITION BY cop.cdagectl) nrqtdrec
         FROM tbcobran_devolucao dev,
              crapban ban,
              crapban ban2,
              crapcop cop
        WHERE dev.cdcooper     = pr_cdcooper
          AND dev.dtmvtolt     = pr_dtmvtolt
          AND cop.cdcooper     = dev.cdcooper
          AND ban2.cdbccxlt    = cop.cdbcoctl 
          AND ban.nrispbif (+) = dev.nrispbif 
          AND ban.cdbccxlt (+) = decode(dev.nrispbif,0,1,ban.cdbccxlt(+))
        ORDER BY cop.cdagectl ASC;
                  
     ---------> VARIAVEIS <----------
     vr_cddomes  VARCHAR2(10); 
     vr_dsdlinha VARCHAR2(200);   
     vr_dschave_troca VARCHAR2(160);
     vr_nrseqlin INTEGER;
     vr_vltotarq NUMBER;
     vr_dsdircop_arq VARCHAR2(100);
     vr_dsdirmic_arq VARCHAR2(100);
             
     vr_dslobdev      CLOB;
     vr_dsbufdev      VARCHAR2(32700);
     vr_dtultdia      DATE;
                        
    BEGIN

     --06/12/2017
     --Rotina para achar o ultimo dia útil do ano
     vr_dtultdia := add_months(TRUNC(vr_dtmvtpro,'RRRR'),12)-1;    
     CASE to_char(vr_dtultdia,'d') 
       WHEN '1' THEN vr_dtultdia := vr_dtultdia - 2;
       WHEN '7' THEN vr_dtultdia := vr_dtultdia - 1;
       ELSE vr_dtultdia := add_months(TRUNC(vr_dtmvtpro,'RRRR'),12)-1;
     END CASE;        

     -- se a data de devolução for o ultimo dia do ano, entao o arquivo de devolução
     -- deverá ser com a data do próximo dia útil     
     IF vr_dtultdia = vr_dtmvtpro THEN
       vr_dtmvtpro := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                  pr_dtmvtolt  => vr_dtmvtpro + 1,
                                                  pr_tipo      => 'P',
                                                  pr_feriado   => TRUE,
                                                  pr_excultdia => TRUE);
     END IF;                                                  
           
     -- Definir sigra do mes
     vr_cddomes := replace(to_char(vr_dtmvtpro,'MM'),'0','');
     IF vr_cddomes >= 10 THEN
       CASE vr_cddomes
         WHEN 10 THEN            
           vr_cddomes := 'O';
         WHEN 11 THEN 
           vr_cddomes := 'N';
         WHEN 12 THEN 
           vr_cddomes := 'D';    
         ELSE
           NULL;
       END CASE;     
     END IF; 

     --> Listar devoluoes da coop
     FOR rw_devolucao IN cr_devolucao (pr_dtmvtolt => pr_dtmvtolt ) LOOP

       IF rw_devolucao.nrseqrec = 1 THEN
                 
         vr_nrseqlin := 1;
         vr_vltotarq := 0;
                 
         --> Definir nome do arquivo
         vr_nmarquiv:= '2' ||                                    --> arquivo de cobrança
                       to_char(rw_devolucao.cdagectl,'fm0000')|| --> Agencia
                       vr_cddomes ||                             --> código do mês
                       to_char(vr_dtmvtpro,'DD') ||              --> número do dia do movimento
                       '.DVS';

         -- Inicializar o CLOB
         dbms_lob.createtemporary(vr_dslobdev, TRUE);
         dbms_lob.open(vr_dslobdev, dbms_lob.lob_readwrite);
         vr_dsbufdev := NULL;
                 
         BEGIN 
           --MONTAR HEADER
           vr_dsdlinha := lpad('0',47,'0')                || -->  1 001-047   X(047)  Controle do header 
                          'DVC605'                        || -->  2 048-053   X(006)  Nome do arquivo 
                          '0000001'                       || -->  3 054-060   9(007)  Versão do arquivo
                          lpad(' ',4,' ')                 || -->  4 061-064   X(004)  Filler - Preencher com brancos 
                          '7'                             || -->  5 065-065   9(001)  Indicador de remessa
                          to_char(vr_dtmvtpro,'RRRRMMDD') || -->  6 066-073   9(008)  Data do movimento 
                          lpad(' ',58,' ')                || -->  7 074-131   X(058)  Filler -Preencher com brancos 
                          to_char(rw_devolucao.nrispbif_cop,
                                    'fm00000000')         || -->  8 132-139   9(008)  ISPB IF remetente  
                          lpad(' ',11,' ')                || -->  9 140-150   X(011)  Filler - Preencher com brancos 
                          to_char(vr_nrseqlin,               --> 10 151-160   9(010)  Sequencial de arquivo Número sequencial do registro no arquivo, iniciando em 1 no 
                                    'fm0000000000') || chr(10);                                  --> Header, com evolução de +1 a cada novo registro, inclusive o Trailer ;
                   
           -- Inicilizar as informacoes do XML
           gene0002.pc_escreve_xml(vr_dslobdev,vr_dsbufdev,vr_dsdlinha);
           -- Retorna nome do modulo logado
           GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
             
         EXCEPTION
           WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log
             CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
             vr_dscritic := 'Montar Header do arquivo de devolucao - '||SQLERRM;
             RAISE vr_exc_saida; 
         END;  
       END IF;
               
       --> Incrementar seq
       vr_nrseqlin := vr_nrseqlin + 1;
       vr_vltotarq := vr_vltotarq + rw_devolucao.vlliquid;
               
       BEGIN 
               
         vr_dschave_troca := substr(rw_devolucao.dslinarq,57,57);
               
         --MONTAR LINHA DETALHE
         vr_dsdlinha := rw_devolucao.dscodbar           || -->  1  001-044  X(044)  Código de barras do documento 
                        lpad(' ', 2,' ')                || -->  2  045-046  X(002) Filler - Preencher com brancos 
                        '   '                           || -->  3  047-049  X(003) Filler Preenchimento livre 
                        rw_devolucao.tpcaptura          || -->  4  050-050  9(001) Tipo de captura informado na troca: 
                                                                                  --> 1 (para Guichê de Caixa) 
                                                                                  --> 2 (para Terminal de Auto Atendimento) 
                                                                                  --> 3 (para Internet – home/office banking) 
                                                                                  --> 5 (para Correspondente) 
                                                                                  --> 6 (para Telefone) 
                                                                                  --> 7 (para Arquivo Eletrônico) 
                        to_char(rw_devolucao.cdmotdev,'fm00')  || -->  5  051-052  9(002) Motivo de devolução
                        lpad(' ', 4,' ')                       || -->  6  053-056  X(004) Filler Preencher com branco 
                                
                        vr_dschave_troca  || --> chave para troca extraida da linha original, contem campos abaixo
                                -->  7  057-060  9(004)  Número da agência remetentedo documento na troca 
                                -->  8  061-067  9(007) Número atribuído ao lote que contémo documento na troca 
                                -->  9  068-070  9(003) Número sequencial do documento no lote da troca 
                                --> 10  071-078  9(008)  Data do movimento de troca no formato “AAAAMMDD” 
                                --> 11  079-084  X(006) Centro processador Informação para controle do remetente 
                                --> 12  085-096  9(012) Valor líquido do título
                                --> 13  097-103  9(007) Número da versão do arquivodo remetente da troca 
                                --> 14  104-113  9(010) Número sequencial do registro no arquivo do remetente da troca
                        lpad(' ',18,' ')                                || --> 15  114-131  X(018) Filler - Preencher com brancos 
                        to_char(rw_devolucao.nrispbif,'fm00000000')     || --> 16  132-139  9(008)  Código ISPB do participante recebedor 
                        to_char(rw_devolucao.nrispbif_cop,'fm00000000') || --> 17  140-147  9(008)  Código ISPB do participante favorecido 
                        to_char(41,'fm000')                             || --> 18  148-150  9(003) Tipo de documento 
                        to_char(vr_nrseqlin,'fm0000000000')             || --> 19  151-160  9(010) Sequencial de arquivo
                        chr(10);
                                                       
                 
         -- incluir linha detalhe
         gene0002.pc_escreve_xml(vr_dslobdev,vr_dsbufdev,vr_dsdlinha);
         -- Retorna nome do modulo logado
         GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
       EXCEPTION
         WHEN OTHERS THEN
           -- No caso de erro de programa gravar tabela especifica de log
           CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
           vr_dscritic := 'Montar linha detalhe do arquivo de devolucao - '||SQLERRM;
           RAISE vr_exc_saida; 
       END; 
               
       --> Verificar se é o ultimo registro
       IF rw_devolucao.nrseqrec = rw_devolucao.nrqtdrec THEN
         BEGIN 
           vr_nrseqlin := vr_nrseqlin + 1;

           --MONTAR TRAILER
           vr_dsdlinha := lpad('9',47,'9')                || -->  1 001-047   X(047)  Controle do header 
                          'DVC605'                        || -->  2 048-053   X(006)  Nome do arquivo 
                          '0000001'                       || -->  3 054-060   9(007)  Versão do arquivo
                          lpad(' ',4,' ')                 || -->  4 061-064   X(004)  Filler - Preencher com brancos 
                          '7'                             || -->  5 065-065   9(001)  Indicador de remessa
                          to_char(vr_dtmvtpro,'RRRRMMDD') || -->  6 066-073   9(008)  Data do movimento 
                          to_char(vr_vltotarq * 100,
                                   'fm00000000000000000') || --> 7 074-090 9(017) Somatório do valor dos detalhes do arquivo (*) 
                          lpad(' ',41,' ')                || --> 8  091-131  X(041) Filler - Preencher com brancos
                          to_char(rw_devolucao.nrispbif_cop,
                                    'fm00000000')         || -->  9  132-139  9(008)  ISPB IF remetente
                          lpad(' ',11,' ')                || --> 10 140-150   X(011)  Filler - Preencher com brancos 
                          to_char(vr_nrseqlin,                
                                    'fm0000000000')       || --> 11 151-160   9(010)  Sequencial de arquivo 
                          chr(10);
                                                                                             
           -- Incluir linha trailer e descarregar buffer
           gene0002.pc_escreve_xml(vr_dslobdev,vr_dsbufdev,vr_dsdlinha,TRUE);
           -- Retorna nome do modulo logado
           GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
         EXCEPTION
           WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log
             CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
             vr_dscritic := 'Montar Trailer do arquivo de devolucao - '||SQLERRM;
             RAISE vr_exc_saida; 
         END;

         vr_dsdircop_arq := gene0001.fn_diretorio( pr_tpdireto => 'C', 
                                                   pr_cdcooper => pr_cdcooper, 
                                                   pr_nmsubdir => '/arq');
                 
         vr_dsdirmic_arq := gene0001.fn_diretorio( pr_tpdireto => 'M', 
                                                   pr_cdcooper => pr_cdcooper, 
                                                   pr_nmsubdir => '/abbc');

         -- Geracao do arquivo
         GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper              --> Cooperativa conectada
                                            ,pr_cdprogra  => vr_cdprogra              --> Programa chamador
                                            ,pr_dtmvtolt  => vr_dtmvtaux              --> Data do movimento atual
                                            ,pr_dsxml     => vr_dslobdev              --> Arquivo XML de dados
                                            ,pr_dsarqsaid => vr_dsdircop_arq || '/' || vr_nmarquiv    --> Arquivo final com o path
                                            ,pr_cdrelato  => NULL                     --> Código fixo para o relatório
                                            ,pr_flg_gerar => 'S'                      --> Apenas submeter
                                            ,pr_dspathcop => vr_dsdirmic_arq
                                            ,pr_fldoscop  => 'S'
                                            ,pr_flappend  => 'N'                      --> Indica que a solicitação irá incrementar o arquivo
                                            ,pr_des_erro  => vr_dscritic);            --> Saída com erro                
          -- Retorna nome do modulo logado
          GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
          -- Testar se houve erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar excecao
            vr_dscritic := 'retorno gene0002.pc_solicita_relato_arquivo - ' || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;

          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_dslobdev);
          dbms_lob.freetemporary(vr_dslobdev);
               
       END IF;
               
     END LOOP;

    EXCEPTION
     WHEN vr_exc_saida THEN
       pr_dscritic := vr_dscritic;
       pr_cdcritic := vr_cdcritic;
     WHEN OTHERS THEN
       -- No caso de erro de programa gravar tabela especifica de log
       CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
       --Variavel de erro recebe erro ocorrido
       pr_cdcritic:= NULL;
       pr_dscritic:= sqlerrm;  
               
    END pc_gerar_arq_devolucao;
                    
    --Gerar Relatorio 574
    PROCEDURE pc_gera_relatorio_574(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                   ,pr_cdcritic OUT INTEGER
                                   ,pr_dscritic OUT VARCHAR2) IS
           
    ---------> CURSORES <---------
    --> Listar devoluoes da coop
    CURSOR cr_devolucao(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_dtmvtolt crapdat.dtmvtolt%TYPE )IS
    SELECT dev.dtocorre,
          dev.nrispbif,
          ban.cdbccxlt,
          dev.cdagerem,
          dev.dscodbar,
          dev.vlliquid,
          dev.cdmotdev
     FROM tbcobran_devolucao dev,
          crapban ban
    WHERE dev.cdcooper = pr_cdcooper
      AND dev.dtmvtolt = pr_dtmvtolt
      AND ban.nrispbif (+) = dev.nrispbif
      AND ban.cdbccxlt (+) = decode(ban.nrispbif(+),0,1,ban.cdbccxlt(+));
                  
    ---------> VARIAVEIS <----------
    vr_dsmotdev VARCHAR2(4000);     
           
    BEGIN
           
      vr_nmarqimp:= 'crrl574.lst';

      -- Inicializar o CLOB
      dbms_lob.createtemporary(vr_des_xml, TRUE);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      vr_dstexto:= NULL;
      -- Inicilizar as informacoes do XML
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'<?xml version="1.0" encoding="utf-8"?><crrl574><dados dtmvtolt="'||to_char(vr_dtmvtaux,'DD/MM/YYYY')||'">');
      -- Retorna nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);

      --> Listar devoluoes da coop
      FOR rw_devolucao IN cr_devolucao (pr_cdcooper => pr_cdcooper,
                                     pr_dtmvtolt => pr_dtmvtolt) LOOP
                
      CASE rw_devolucao.cdmotdev
       WHEN 53 THEN
         vr_dsmotdev := 'Apresentação indevida';
       WHEN 63 THEN               
         vr_dsmotdev := 'Código de barras em desacordo com as especificações';
       WHEN 72 THEN
         vr_dsmotdev := 'Devolução de Pagamento Fraudado';
       WHEN 73 THEN
         vr_dsmotdev := 'Beneficiário sem contrato de cobrança';
       WHEN 74 THEN
         vr_dsmotdev := 'Beneficiário inválido ou boleto não encontrado';
       WHEN 77 THEN
         vr_dsmotdev := 'Boleto em cartório ou protestado';
       ELSE
         vr_dsmotdev := 'Descrição de motivo não encontrada';
      END CASE;    

      --Escrever no Arquivo XML
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,
       '<dado>
             <dtocorre>'|| to_char(rw_devolucao.dtocorre,'DD/MM/RRRR')   ||'</dtocorre>'||
            '<nrispbif>'|| rw_devolucao.nrispbif   ||'</nrispbif>'||
            '<cdbccxlt>'|| rw_devolucao.cdbccxlt   ||'</cdbccxlt>'||
            '<cdagerem>'|| rw_devolucao.cdagerem   ||'</cdagerem>'||
            '<dscodbar>'|| rw_devolucao.dscodbar   ||'</dscodbar>'||
            '<vlliquid>'|| to_char(rw_devolucao.vlliquid,'fm999g999g999g990d00')  ||'</vlliquid>'||
            '<cdmotdev>'|| rw_devolucao.cdmotdev   ||'</cdmotdev>'||
            '<dsmotdev>'|| gene0007.fn_caract_acento(vr_dsmotdev) ||'</dsmotdev>
        </dado>');        
        -- Retorna nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
      END LOOP;

      -- Finalizar tag XML
      gene0002.pc_escreve_xml(vr_des_xml,vr_dstexto,'</dados></crrl574>',true);
      -- Retorna nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);

      /*  Salvar copia relatorio para "/rlnsv"  */
      IF pr_nmtelant = 'COMPEFORA' THEN
        vr_flpdfcopi:= 'S';
      ELSE
        vr_flpdfcopi:= 'N';
      END IF;

      -- Efetuar solicitacao de geracao de relatorio crrl574 --
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => vr_dtmvtaux         --> Data do movimento atual
                                 ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl574/dados/dado'  --> N? base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl574.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                --> Titulo do relat?rio
                                 ,pr_dsarqsaid => vr_caminho_rl||'/'||vr_nmarqimp --> Arquivo final
                                 ,pr_qtcoluna  => 132                 --> 132 colunas
                                 ,pr_sqcabrel  => 2                   --> Sequencia do Relatorio {includes/cabrel132_2.i}
                                 ,pr_flg_impri => 'S'                 --> Chamar a impress?o (Imprim.p)
                                 ,pr_nmformul  => NULL                --> Nome do formul?rio para impress?o
                                 ,pr_nrcopias  => 1                   --> N?mero de c?pias
                                 ,pr_flg_gerar => 'S'                 --> gerar PDF
                                 ,pr_dspathcop => vr_caminho_rlnsv    --> Lista sep. por ';' de diretórios a copiar o relatório
                                 ,pr_des_erro  => vr_dscritic);       --> Sa?da com erro
      -- Retorna nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
      
      -- Testar se houve erro
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := 'retorna gene0002.pc_solicita_relato - ' || vr_dscritic;
        -- Gerar excecao
        RAISE vr_exc_saida;
      END IF;

      -- Liberando a memoria alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      vr_dstexto:= NULL;
           
    EXCEPTION
      -- apenas repassar as criticas
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        pr_cdcritic := vr_cdcritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= NULL;
        pr_dscritic:= sqlerrm;           
    END pc_gera_relatorio_574;
                        
    --Gera Arq pc_trata_arq_cooperado 
    PROCEDURE pc_gera_arq_cooperado(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                   ,pr_cdcritic OUT INTEGER
                                   ,pr_dscritic OUT VARCHAR2
                                    ) 
    IS         
      --Selecionar informacoes convenios ativos
      CURSOR cr_crapcco_ativo (pr_cdcooper IN crapcco.cdcooper%type
                               ,pr_cddbanco IN crapcco.cddbanco%type) IS
         SELECT crapcco.cdcooper
               ,crapcco.nrconven
               ,crapcco.nrdctabb
               ,crapcco.cddbanco
               ,crapcco.cdagenci
               ,crapcco.cdbccxlt
               ,crapcco.nrdolote
               ,crapcco.dsorgarq
         FROM crapcco
         WHERE crapcco.cdcooper = pr_cdcooper
         AND   crapcco.cddbanco = pr_cddbanco
         AND   crapcco.flgregis = 1;
         
    BEGIN
    
      -- Busca todos os convenios da IF CECRED que foram gerados pela internet
      FOR rw_crapcco IN cr_crapcco_ativo(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_cddbanco => rw_crapcop.cdbcoctl) LOOP
        
        -- Rotina padrão de geração de Log   
        pc_controla_log_programa('O', -- Tipo de Log
                                 4,
                                 'Gerando arq retorno ao cooperado: convenio ' ||
                                  to_char(rw_crapcco.nrconven));  -- Descrição da mensagem
        
        -- Gerar e enviar arquivo de retorno para o cooperado
        PAGA0001.pc_gera_arq_cooperado(pr_cdcooper => rw_crapcco.cdcooper   --Codigo Cooperativa 
                                      ,pr_nrcnvcob => rw_crapcco.nrconven   --Numero Convenio
                                      ,pr_nrdconta => 0                     --Numero da Conta
                                      ,pr_dtmvtolt => vr_dtmvtaux           --Data pagamento
                                      ,pr_idorigem => 1  -- AYLLOS          --Identificador Origem
                                      ,pr_flgproce => 0  -- false           --Flag Processo
                                      ,pr_cdprogra => vr_cdprogra           --Nome Programa
                                      ,pr_tab_arq_cobranca => vr_tab_arq_cobranca --Tabela Cobranca
                                      ,pr_cdcritic => vr_cdcritic           --Codigo da Critica
                                      ,pr_dscritic => vr_dscritic);         --Descricao da critica

        -- Retorna nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          vr_dscritic := 'Retorno PAGA0001.pc_gera_arq_cooperado - ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
           
      END LOOP;
      
    EXCEPTION
      -- apenas repassar as criticas
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        pr_cdcritic := vr_cdcritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= NULL;
        pr_dscritic:= sqlerrm;           
    END pc_gera_arq_cooperado; 
                                       
    -- pc_verifica_ja_executou
    PROCEDURE pc_verifica_ja_executou(pr_cdcooperexec IN NUMBER
                                     ,pr_dtprocess    IN DATE
                                     ,pr_cdtipope     IN VARCHAR2
                                     ,pr_cdprogra     IN VARCHAR2
                                     ,pr_qtdexec      OUT INTEGER
                                     ,pr_cdcritic     OUT INTEGER
                                     ,pr_dscritic     OUT VARCHAR2
                                ) 
    IS    
      vr_flultexe    INTEGER          := NULL;
      vr_qtdexec     INTEGER          := NULL;
      vr_cdcritic    PLS_INTEGER      := NULL;
      vr_dscritic    VARCHAR2(4000)   := NULL;
    BEGIN
      --> Verificar a execução
      CECRED.gene0001.pc_controle_exec(pr_cdcooper  => pr_cdcooperexec         --> Código da coopertiva
                                      ,pr_cdtipope  => pr_cdtipope           --> Tipo de operacao I-incrementar e C-Consultar
                                      ,pr_dtmvtolt  => pr_dtprocess      --> Data do movimento
                                      ,pr_cdprogra  => pr_cdprogra       --> Codigo do programa
                                      ,pr_flultexe  => vr_flultexe       --> Retorna se é a ultima execução do procedimento
                                      ,pr_qtdexec   => vr_qtdexec        --> Retorna a quantidade
                                      ,pr_cdcritic  => vr_cdcritic       --> Codigo da critica de erro
                                      ,pr_dscritic  => vr_dscritic);     --> descrição do erro se ocorrer
      -- Retorna nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);
      pr_qtdexec := vr_qtdexec;                                                               
      --Trata retorno
      IF nvl(vr_cdcritic,0) > 0         OR
        TRIM(vr_dscritic)   IS NOT NULL THEN
          RAISE vr_exc_saida;
      END IF;
    EXCEPTION
      -- apenas repassar as criticas
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Retorno gene0001.pc_controle_exec - ' || vr_dscritic ||
                       ' - dtprocess: '  || pr_dtprocess   ||
                       ' - cdtipope: '   || pr_cdtipope    ||
                       ' - cdprogra: '   || pr_cdprogra;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= 'Retorno gene0001.pc_controle_exec - ' || sqlerrm;           
    END pc_verifica_ja_executou; 
                                        
    -- pc_avalia_execucao 
    PROCEDURE pc_avalia_execucao(pr_cdcritic OUT INTEGER
                                ,pr_dscritic OUT VARCHAR2
                                ) 
    IS    
    BEGIN           
      --Inicializar contador
      vr_contador       := 0;
      --Filtro arquivo retorno
      vr_nmarqret       := '29999%.RET';

      --Verifica se é o último dia do mês
      --Se for último dia do mês, nesse caso deve ler os arquivos da pasta "win12\salvar"
      --IF trunc(sysdate) = trunc(last_day(vr_dtmvtaux)) THEN

      --se o mês de dtmvtoan é diferente do mês de dtmvtolt SD#842900
      if to_char(vr_dtmvtaux /*rw_crapdat.dtmvtoan*/,'yyyymm')
      <> to_char(vr_dtmvtpro /*rw_crapdat.dtmvtolt*/,'yyyymm') then
        --Buscar Diretorio Integracao da Cooperativa
        vr_caminho_puro := gene0001.fn_diretorio(pr_tpdireto => 'W' --> Usr/Coop/Win12
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => NULL);   
      
      ELSE
        --Se não, continua lendo os arquivos da pasta "\salvar"
        --Buscar Diretorio Integracao da Cooperativa
        vr_caminho_puro   := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => NULL);   

      END IF;
      --

      -- Buscar o diretorio padrao da cooperativa conectada
      vr_caminho_salvar := vr_caminho_puro||'/salvar';

      --Listar arquivos no diretorio
      gene0001.pc_lista_arquivos(pr_path     => vr_caminho_salvar
                                ,pr_pesq     => vr_nmarqret
                                ,pr_listarq  => vr_listadir
                                ,pr_des_erro => vr_dscritic);
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;

      --Montar vetor com nomes dos arquivos
      vr_tab_nmarqtel:= GENE0002.fn_quebra_string(pr_string => vr_listadir);

      --Se nao encontrou arquivos
      IF vr_tab_nmarqtel.COUNT <= 0 THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 182;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        pc_controla_log_programa('O', 4, vr_dscritic || ' - Arquivo: integra/'||vr_nmarqret);         
        --Levantar Excecao pois nao tem arquivo para processar
        RAISE vr_exc_final;
      END IF;

      --Inicializar variaveis
      vr_inreproc  := FALSE;      
      vr_intemarq  := FALSE;                        

      --Percorrer todos os arquivos
      FOR idx IN 1..vr_tab_nmarqtel.COUNT LOOP

        -- Verificar o Header  - Comando para listar a primeira linha do arquivo
        vr_comando:= 'head -1 ' ||vr_caminho_salvar||'/'||vr_tab_nmarqtel(idx);  

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_setlinha);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Não foi possivel executar comando unix. '||vr_comando;
          RAISE vr_exc_saida;
        END IF;

        --Montar Tipo Cobranca
        vr_dstipcob:= SUBSTR(vr_setlinha,48,6);
        --Montar Data Arquivo
        vr_dtleiaux:= SUBSTR(vr_setlinha,66,8);

        -- Verifica a primeira linha do arquivo importado
        IF SUBSTR(vr_setlinha,1,10) <> '0000000000'  THEN
          vr_cdcritic:= 468;
        ELSIF vr_dstipcob <> 'COB615' THEN
          vr_cdcritic:= 181;
        END IF;
    
        --Se ocorreu algum erro na validacao
        IF NVL(vr_cdcritic,0) <> 0 THEN
          --Buscar descricao da critica
          vr_dscritic  := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          -- Envio centralizado de log de erro        
          pc_controla_log_programa('E', 2, vr_dscritic||' - Arquivo: integra/'||vr_tab_nmarqtel(idx)); 
          --Zerar variavel critica
          vr_cdcritic  := NULL;
          vr_dscritic  := NULL;
          --Ir para proximo arquivo
          CONTINUE;
        END IF;                       
        
        -- Verificar se o arquivo é um REPROC 
        IF TRIM(SUBSTR(vr_setlinha,99,3)) = 'REP' THEN
          -- Indica que o arquivo é de reprocessamento
          vr_inreproc := TRUE;
        ELSE     
          vr_intemarq := TRUE;            
        END IF;  
      END LOOP; --Contador arquivos           

      -- Não é reprocesso, então processa
      IF NOT vr_inreproc THEN
        -- tem arquivo para processar
        IF vr_intemarq THEN
          -- Gera arq cooperado
          pc_gera_arq_cooperado(pr_cdcooper => pr_cdcooper
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            vr_dscritic := 'pc_gera_arq_cooperado - '||vr_dscritic;
            RAISE vr_exc_saida;
          END IF;              
        END IF;                  
      END IF;    

    EXCEPTION
      WHEN vr_exc_final THEN
        --nao tem arquivo para processar
        pr_cdcritic:= NULL;
        pr_dscritic:= NULL;
      WHEN vr_exc_saida THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= NULL;
        pr_dscritic:= sqlerrm;      
    END pc_avalia_execucao;               
                                    
    -- pc_posiciona_dat 
    PROCEDURE pc_posiciona_dat(pr_cdcooperprog IN crapcop.cdcooper%TYPE
                              ,pr_fgferiado    OUT BOOLEAN
                              ,pr_cdcritic     OUT INTEGER
                              ,pr_dscritic     OUT VARCHAR2
                              ) 
    IS
      vr_dataexecucao       DATE      := (SYSDATE-1);
      vr_datautil           DATE      := SYSDATE;
    BEGIN
      pr_fgferiado := FALSE;
      -- trata feriado
      vr_datautil := GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooperprog --in crapcop.cdcooper%type, --> Cooperativa conectada
                                                ,pr_dtmvtolt => vr_dataexecucao --in crapdat.dtmvtolt%type, --> Data do movimento
                                                 --pr_tipo in varchar2 default 'P',      --> Tipo de busca (P = proximo, A = anterior)
                                                 --pr_feriado IN BOOLEAN DEFAULT TRUE,   --> Considerar feriados
                                                 --pr_excultdia IN BOOLEAN DEFAULT FALSE --> Desconsiderar Feriado 31/12
                                                 );
      IF vr_datautil <> vr_dataexecucao THEN
        pr_fgferiado := FALSE;
      END IF;
      
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooperprog);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      --Esse processa executa após o termino da cadeia então busca as datas anteriores                        
      --Determinar a data para arquivo de retorno
      vr_dtmvtaux := rw_crapdat.dtmvtoan;  
      vr_dtmvtpro := rw_crapdat.dtmvtolt;        
      -- Verifica se a cadeia da cooperativa especifica terminou
      vr_inproces := rw_crapdat.Inproces;        

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic := NULL;
        pr_dscritic := sqlerrm;      
    END pc_posiciona_dat;   
                                    
    -- pc_detalhe_execucao 
    PROCEDURE pc_detalhe_execucao(pr_cdcritic OUT INTEGER
                                 ,pr_dscritic OUT VARCHAR2
                                 ) 
    IS
    BEGIN
      
      -- Verifica se programa anterior já executou
      pc_verifica_ja_executou( pr_cdcooperexec => pr_cdcooper
                              ,pr_dtprocess => vr_dtmvtaux
                              ,pr_cdtipope  => 'C'
                              ,pr_cdprogra  => 'CRPS538_1'
                              ,pr_qtdexec   => vr_qtdexec
                              ,pr_cdcritic  => vr_cdcritic
                              ,pr_dscritic  => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        vr_dscritic := 'pc_verifica_ja_executou - CRPS538_1 - '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;

      IF vr_qtdexec = 0 THEN
        --Levantar Excecao
        vr_dscritic := 'Faltou executar programa anterior crps538_1';
        RAISE vr_exc_saida;
      END IF;
      -- Verifica se programa já executou
      pc_verifica_ja_executou( pr_cdcooperexec => pr_cdcooper
                              ,pr_dtprocess => vr_dtmvtaux
                              ,pr_cdtipope  => 'I'
                              ,pr_cdprogra  => vr_cdprogra
                              ,pr_qtdexec   => vr_qtdexec
                              ,pr_cdcritic  => vr_cdcritic
                              ,pr_dscritic  => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        vr_dscritic := 'pc_verifica_ja_executou - '||vr_cdprogra||' - '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;                       
      
      -- Busca o diretorio da cooperativa conectada
      vr_caminho_rl := gene0001.fn_diretorio(pr_tpdireto => 'C' --> usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => NULL);									  
      -- Buscar o diretorio padrao da cooperativa conectada
      vr_caminho_rl  := vr_caminho_rl||'/rl';		

      pc_avalia_execucao(pr_cdcritic => vr_cdcritic
                        ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        vr_dscritic := 'pc_avalia_execucao - '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;                      

      --Gerar relatorio 574
      pc_gera_relatorio_574(pr_cdcooper => pr_cdcooper
                           ,pr_dtmvtolt => vr_dtmvtaux
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        vr_dscritic := 'pc_gera_relatorio_574 - '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;          

      --Gerar arq devolução
      pc_gerar_arq_devolucao(pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => vr_dtmvtaux
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        vr_dscritic := 'pc_gerar_arq_devolucao - ' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;             

      pc_controla_log_programa('O'
                              ,4
                              ,'Executou pc_detalhe_execucao, dtmvtaux: ' ||vr_dtmvtaux||' , cdprogra: '||vr_cdprogra
                              ,rw_crapcop_ativas.cdcooper
                              );
            
    EXCEPTION
      WHEN vr_exc_final THEN
        --nao tem arquivo para processar
        pr_cdcritic:= NULL;
        pr_dscritic:= NULL;
      WHEN vr_exc_saida THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= NULL;
        pr_dscritic:= sqlerrm;      
    END pc_detalhe_execucao;      
                                    
    -- pc_cria_job 
    PROCEDURE pc_cria_job(pr_cdcooperprog IN crapcop.cdcooper%TYPE
                         ,pr_qtminutos    IN NUMBER
                         ,pr_cdcritic     OUT INTEGER
                         ,pr_dscritic     OUT VARCHAR2
                         ) 
    IS
      vr_jobname  VARCHAR2  (100);
      vr_dsplsql  VARCHAR2 (4000);
    BEGIN    
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      vr_jobname  := 'JBCOBRAN_ARQCO_' || pr_cdcooperprog||'_'||'$';
      vr_dsplsql  := 
      'DECLARE
         vr_cdcritic     INTEGER:= 0;
         vr_dscritic     VARCHAR2(4000);
       BEGIN
         CECRED.PC_CRPS538_2
         ( pr_flavaexe  => ''N''
         , pr_cdcooper  => ' || pr_cdcooperprog ||
       ' , pr_nmtelant  => ''DIARIA''
         , pr_cdcritic  => vr_cdcritic  
         , pr_dscritic  => vr_dscritic
         );
         IF vr_dscritic IS NOT NULL THEN
           raise_application_error(-20001,vr_dscritic);
         END IF;
       END;';
      -- Faz a chamada ao programa paralelo atraves de JOB
      gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooperprog --> Código da cooperativa
                            ,pr_cdprogra  => vr_cdprogra     --> Código do programa
                            ,pr_dsplsql   => vr_dsplsql      --> Bloco PLSQL a executar
                            ,pr_dthrexe   => ( SYSDATE + (pr_qtminutos /1440) ) --> Horario da execução
                            ,pr_interva   => NULL            --> apenas uma vez
                            ,pr_jobname   => vr_jobname      --> Nome randomico criado
                            ,pr_des_erro  => vr_dscritic);

      IF TRIM(vr_dscritic) is not null THEN
        vr_dscritic := 'retorno gene0001.pc_submit_job' ||
                       ' , vr_jobname: '  || vr_jobname ||
                       ' , vr_dsplsql: '   || vr_dsplsql ||
                       ' , vr_dscritic: '  || vr_dscritic;
        RAISE vr_exc_saida;              
      END IF;  
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= NULL;
        pr_dscritic:= sqlerrm;      
    END pc_cria_job;  
        
    -- Verifica termino de todas coooperativas e do ultimo 538_2 
    PROCEDURE pc_ver_termino_coopers(pr_interminocoopers OUT NUMBER -- indica termino de todas coopers
                                    ,pr_cdcritic         OUT INTEGER
                                    ,pr_dscritic         OUT VARCHAR2
                                    )
    IS
       -- Selecionar lista de Cooperativas ativas
       CURSOR cr_crapcop_termino  IS
       SELECT
         cop.cdcooper, dat.inproces, dat.dtmvtolt
         FROM crapcop cop, crapdat dat
         WHERE cop.flgativo = 1
         AND   cop.cdcooper <> 3
         AND   dat.cdcooper = cop.cdcooper
         ORDER BY cop.cdcooper;
       rw_crapcop_termino  cr_crapcop_termino%ROWTYPE;    
    BEGIN
      pr_interminocoopers := 1;
      -- selecionar todas cooperativas ativas
      FOR rw_crapcop_termino IN cr_crapcop_termino  LOOP        
        -- Verifica se a cadeia da cooperativa especifica terminou
        IF NVL(rw_crapcop_termino.inproces,0) <> 1 THEN
          pr_interminocoopers := 2;
          EXIT;
        ELSE
          -- Verifica se programa 538_2 já executou
          pc_verifica_ja_executou( pr_cdcooperexec => rw_crapcop_termino.cdcooper
                                  ,pr_dtprocess => vr_dtmvtaux
                                  ,pr_cdtipope  => 'C'
                                  ,pr_cdprogra  => 'CRPS538_2'
                                  ,pr_qtdexec   => vr_qtdexec
                                  ,pr_cdcritic  => vr_cdcritic
                                  ,pr_dscritic  => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            vr_dscritic := 'pc_verifica_ja_executou - '||vr_dscritic;
            RAISE vr_exc_saida;
          END IF;
      
          IF vr_qtdexec = 0 THEN
            pr_interminocoopers := 2;
            EXIT;
          END IF;
          
        END IF;
      END LOOP;  
      
    EXCEPTION
      -- apenas repassar as criticas
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        pr_cdcritic := vr_cdcritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= NULL;
        pr_dscritic:= sqlerrm;      
    END pc_ver_termino_coopers;                                    
                                        
    -- pc_controle_coop_especifica 
    PROCEDURE pc_controle_coop_especifica(pr_cdcritic OUT INTEGER
                                         ,pr_dscritic OUT VARCHAR2
                                         ) 
    IS
    BEGIN      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF; 
                
      pc_posiciona_dat(pr_cdcooperprog => pr_cdcooper
                      ,pr_fgferiado    => vr_fgferiado
                      ,pr_cdcritic     => vr_cdcritic
                      ,pr_dscritic     => vr_dscritic
                      );
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        vr_dscritic := 'pc_posiciona_dat - '||vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      -- verifica se ontem foi feriado e se for gera erro para chamado
      IF vr_fgferiado THEN
        vr_dscritic := 'Rotina não executa em feriado';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_cdcooper = 3 THEN
        pc_ver_termino_coopers(pr_interminocoopers => vr_interminocoopers -- indica termino de todas coopers
                              ,pr_cdcritic         => vr_cdcritic
                              ,pr_dscritic         => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          vr_dscritic := 'pc_ver_termino_coopers - '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
      ELSE    
        -- Para coopers clientes não verifica a regra de termino então fica 1 fixo
        vr_interminocoopers := 1;
      END IF; 
                            
      IF vr_inproces         = 1 AND -- Verifica se a cadeia da cooperativa especifica terminou
         vr_interminocoopers = 1     -- Verifica termino de todas coopers
        THEN
       
        pc_detalhe_execucao(pr_cdcritic     => vr_cdcritic
                           ,pr_dscritic     => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          vr_dscritic := 'pc_detalhe_execucao - '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
      ELSE         
        --Chamado 809421
        vr_qtminutos := NVL(gene0001.fn_param_sistema('CRED'
                                                     ,0
                                                     ,'TEMPO_ESPERA_CRPS538_2'),5);

        pc_cria_job(pr_cdcooperprog => pr_cdcooper
                   ,pr_qtminutos    => vr_qtminutos
                   ,pr_cdcritic     => vr_cdcritic
                   ,pr_dscritic     => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          vr_dscritic := 'pc_cria_job - '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
      END IF;           
      
    EXCEPTION
      WHEN vr_exc_final THEN
        --nao tem arquivo para processar
        pr_cdcritic:= NULL;
        pr_dscritic:= NULL;
      WHEN vr_exc_saida THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= NULL;
        pr_dscritic:= sqlerrm;      
    END pc_controle_coop_especifica;  
                                    
    -- pc_controle_execucao 
    PROCEDURE pc_controle_execucao(pr_cdcritic OUT INTEGER
                                  ,pr_dscritic OUT VARCHAR2
                                ) 
    IS
     vr_totcoop            NUMBER(4) := 0;
     vr_diaSemana          NUMBER(1) := 0;
    BEGIN
               
      -- selecionar todas cooperativas ativas
      FOR rw_crapcop_ativas IN cr_crapcop_ativas  LOOP
        
        -- verifica a quantidade de cooperativas a processar
        vr_totcoop := vr_totcoop + 1;
        
        -- Verifica sabado para não executar a Cecred
        BEGIN
          SELECT TO_CHAR(SYSDATE,'D') 
          INTO   vr_diaSemana 
          FROM   DUAL;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
            --Variavel de erro recebe erro ocorrido
            vr_cdcritic:= 0;
            vr_dscritic:= 'Select dia da semana - ' || sqlerrm;
            RAISE vr_exc_saida;    
        END;
        
        IF vr_diaSemana                  = 1     THEN -- domingo não executa nenhuma cooper
          CONTINUE; 
        ELSIF vr_diaSemana               = 2 AND      -- segunda 
              rw_crapcop_ativas.cdcooper <> 3    THEN -- Processa somente a cooper Cecred                                                                       
          CONTINUE;             
        ELSIF vr_diaSemana               = 7 AND      -- sabado  
              rw_crapcop_ativas.cdcooper = 3     THEN -- Não Processa apenas a cooper Cecred                                                      
          CONTINUE;
        END IF;
                
        pc_posiciona_dat(pr_cdcooperprog => rw_crapcop_ativas.cdcooper
                        ,pr_fgferiado    => vr_fgferiado
                        ,pr_cdcritic     => vr_cdcritic
                        ,pr_dscritic     => vr_dscritic
                        );
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          vr_dscritic := 'pc_posiciona_dat - '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
        -- verifica se ontem foi feriado e se for: Rotina não será executada
        IF vr_fgferiado THEN
          pc_controla_log_programa('O', 4,  'Feriado então Rotina não será executada', rw_crapcop_ativas.cdcooper);          
          CONTINUE;
        END IF;
                
        -- Verifica se a cadeia da cooperativa especifica terminou
        IF vr_inproces = 1 THEN
          vr_qtminutos := 2;
        ELSE         
          --Chamado 809421
          vr_qtminutos := NVL(gene0001.fn_param_sistema('CRED'
                                                       ,0
                                                       ,'TEMPO_ESPERA_CRPS538_2'),5); 

        END IF;
        
        pc_cria_job(pr_cdcooperprog => rw_crapcop_ativas.cdcooper
                   ,pr_qtminutos    => vr_qtminutos
                   ,pr_cdcritic     => vr_cdcritic
                   ,pr_dscritic     => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          vr_dscritic := 'pc_cria_job - '||vr_dscritic;
          RAISE vr_exc_saida;
        END IF;
             
      END LOOP;
      
      -- Verifica quantidade de cooperativas a processar
      IF vr_totcoop = 0 THEN
        vr_cdcritic:= 0;
        vr_dscritic := 'Não encontrada nenhuma cooperativa ativa ou cadastrada';
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_final THEN
        --nao tem arquivo para processar
        pr_cdcritic:= NULL;
        pr_dscritic:= NULL;
      WHEN vr_exc_saida THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        --Variavel de erro recebe erro ocorrido
        pr_cdcritic:= NULL;
        pr_dscritic:= sqlerrm;      
    END pc_controle_execucao;              
    
    ---------------------------------------
    --                                           Inicio Bloco Principal 
    ---------------------------------------
    BEGIN

      --Limpar parametros saida
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      -- Retorna nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => vr_cdprogra, pr_action => NULL);

      --Programa CRPS538_2 iniciado
      pc_controla_log_programa('I', NULL, NULL);

      IF pr_flavaexe = 'S' THEN      
        --pc_controle_execucao
        pc_controle_execucao(pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          vr_dscritic := 'pc_controle_execucao - ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;       
      ELSE

        pc_controle_coop_especifica(pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          vr_dscritic := 'pc_controle_coop_especifica - ' || vr_dscritic;
          RAISE vr_exc_saida;
        END IF;       
      END IF;      

      --Salvar informacoes no banco de dados
      COMMIT;
      
      -- Programa CRPS538_2 Finalizado com Sucesso
      pc_controla_log_programa('F', NULL, NULL);
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Devolvemos codigo e critica encontradas	   
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic, vr_dscritic);
        pc_controla_log_programa('E', 2, pr_dscritic);
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        pc_controla_log_programa('E', 2, sqlerrm);
    END;
  END PC_CRPS538_2;
/
