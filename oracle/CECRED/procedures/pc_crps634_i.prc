CREATE OR REPLACE PROCEDURE CECRED.pc_crps634_i(pr_cdcooper IN NUMBER                      --> Código da cooperativa
                                        ,pr_cdagenci    IN PLS_INTEGER                        --> Código da agência
                                        ,pr_cdoperad    IN VARCHAR2                           --> Código do cooperado
                                        ,pr_cdprogra    IN VARCHAR2                           --> Código do programa
                                        ,pr_persocio    IN NUMBER                             --> Percentual dos sócios
                                        ,pr_tab_crapdat IN OUT btch0001.rw_crapdat%TYPE           --> Pool de consulta de datas do sistema
                                        ,pr_impcab      IN VARCHAR2 DEFAULT 'N'               --> Controle de impressão de cabeçalho
                                        ,pr_idparale    IN PLS_INTEGER DEFAULT 0              --> Identificador do job executando em paralelo.                      
                                        ,pr_stprogra    OUT PLS_INTEGER                       --> Saída de termino da execução
                                        ,pr_infimsol    OUT PLS_INTEGER                       --> Saída de termino da solicitação
                                        ,pr_cdcritic    OUT PLS_INTEGER                       --> Código crítica
                                        ,pr_dscritic    OUT VARCHAR2) IS                      --> Descrição crítica
  /* ..........................................................................

   Programa: PC_CRPS634_I   (antigo Includes/crps634.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CECRED
   Autor   : Adriano
   Data    : Dezembro/2012                     Ultima atualizacao: 17/03/2014

   Dados referentes ao programa:

   Frequencia: Diario(crps634)/Mensal(crps627).
   Objetivo  : Realiza a formacao do grupo economico.


   Alteracoes: 28/03/2013 - Incluido a passagem do parametro cdprogra na
                            chamada da procedure forma_grupo_economico
                            (Adriano).

               18/04/2013 - Ajustes realizados:
                             - Colocado no-undo nas temp-tables tt-erro,
                               tt-grupo-economico;
                             - Relatorio (crrl628): Invertido a ordem das
                               colunas "PAC GRUPO", alterado o label da coluna
                               "Conta SOC" para "Conta/DV" e pulado uma linha
                               ao final de cada grupo (Adriano).

               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).

               13/09/2013 - Conversão Progress >> PLSQL (Petter-Supero)

               17/03/2014 - Ajustes na chamada do relatório, passando direto
                            o pr_cdrelato e não mais o pr_seqabrel (Marcos-Supero)

  ............................................................................. */
BEGIN
  DECLARE
    vr_nmarquiv    VARCHAR2(256);             --> Nome do arquivo
    vr_nom_dir     VARCHAR2(400);             --> Path do arquivo
    vr_tab_craterr GENE0001.typ_tab_erro;     --> PL Table de erros do sistema
    vr_tab_crapgrp geco0001.typ_tab_crapgrp;  --> PL Table para grupo economico
    vr_exc_erro    EXCEPTION;                 --> Controle de exceção
    vr_cdprogra    VARCHAR2(40);              --> Nome do programa
    vr_index       VARCHAR2(100);             --> Índice para a PL Table
    vr_indexd      VARCHAR2(100);             --> Indice para exclusão da PL Table
    vr_controle    BOOLEAN := FALSE;          --> Controle se a iteração acesso a cooperativa correta
    vr_xmlbuffer   VARCHAR2(32767);           --> Buffer para geração do XML
    vr_xml         CLOB;                      --> XML para criar relatório
    vr_nmformul    VARCHAR2(40);              --> Nome do formulário
    vr_nrcopias    NUMBER;                    --> Número de cópias
    vr_idparale    integer;                   --> ID para o paralelismo
    vr_qtdjobs     number;                    --> Qtde parametrizada de Jobs (Paralelismo)
    vr_dtmvtopr    crapdat.dtmvtopr%type;     --> Data do movimento da coperativa
    vr_inproces    crapdat.inproces%type;     
    rw_crapdat     btch0001.cr_crapdat%rowtype;          --> Registro para armazenar as datas
    vr_ds_xml      tbgen_batch_relatorio_wrk.dscritic%type; --> acumula registro para gravar na (tbgen_batch_relatorio_wrk - paralelismo)
    ds_character_separador constant varchar2(1) := '#';  --> separador para utilizar tabela (tbgen_batch_relatorio_wrk  - paralelismo) 
    vr_qterro        number := 0; 
    vr_tpexecucao   integer := 0;
    vr_idlog_ini_ger tbgen_prglog.idprglog%type;
    vr_idlog_ini_par tbgen_prglog.idprglog%type;
    vr_cdcritic      integer:= 0;
    vr_dscritic      varchar2(4000);
    vr_exc_saida     exception;
    vr_jobname       varchar2(30);
    vr_dsplsql       varchar2(4000);
    vr_indice_agencia    number(10); --> Índices para leitura das pl/tables ao gerar o XML
    vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE; 
    pr_nrdcaixa PLS_INTEGER;
    vr_dstextab     craptab.dstextab%type; --> Descriçao do texto do parametro 
    opt_dsdrisco    VARCHAR2(400);     --> Opção para descrição de risco
    opt_vlendivi    NUMBER;            --> Opção para valor de dívida
    
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE)IS
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdcooper
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;


    -- Agências de empresas com ações societárias em outras empresas
    cursor cr_crapepa_age (pr_cdcooper in crapage.cdcooper%type,
                           pr_qterro   in number,
                           pr_dtmvtolt in tbgen_batch_controle.dtmvtolt%TYPE) is

         SELECT distinct cs.cdagenci
        FROM crapass cs
        WHERE cs.cdcooper = pr_cdcooper
        AND (pr_qterro = 0 or
            (pr_qterro > 0 and exists (SELECT 1
                                          FROM tbgen_batch_controle
                                       WHERE tbgen_batch_controle.cdcooper    = pr_cdcooper
                                           AND tbgen_batch_controle.cdprogra    = pr_cdprogra
                                           AND tbgen_batch_controle.tpagrupador = 1
                                           AND tbgen_batch_controle.cdagrupador = cs.cdagenci
                                           AND tbgen_batch_controle.insituacao  = 1
                                           AND tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)));       

          
   /* Buscar dados da formação de grupos */
   CURSOR cr_crapgrpb(pr_cdcooper IN crapgrp.cdcooper%TYPE) IS  --> Código da cooperativa
        SELECT distinct cg.nrdgrupo
              ,NVL((LAG(cg.nrdgrupo) OVER(ORDER BY cg.nrdgrupo)), 0) nrdgrupoa
        FROM crapgrp cg
        WHERE cg.cdcooper = pr_cdcooper
        ORDER BY cg.nrdgrupo;          
          
          
   PROCEDURE pc_carrega_tabgrupo (pr_cdcooper in tbgen_batch_relatorio_wrk.cdcooper%type,
                                pr_dtmvtolt in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                pr_des_erro out varchar2) IS
        cursor c_crapgrupo is                         
		    select substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,1) +1,instr(tab.DSCRITIC,'#',1,2)-instr(tab.DSCRITIC,'#',1,1)-1) cdcooper,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,2) +1,instr(tab.DSCRITIC,'#',1,3)-instr(tab.DSCRITIC,'#',1,2)-1) nrdgrupo,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,3) +1,instr(tab.DSCRITIC,'#',1,4)-instr(tab.DSCRITIC,'#',1,3)-1) nrctasoc,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,4) +1,instr(tab.DSCRITIC,'#',1,5)-instr(tab.DSCRITIC,'#',1,4)-1) nrdconta,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,5) +1,instr(tab.DSCRITIC,'#',1,6)-instr(tab.DSCRITIC,'#',1,5)-1) idseqttl,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,6) +1,instr(tab.DSCRITIC,'#',1,7)-instr(tab.DSCRITIC,'#',1,6)-1) nrcpfcgc,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,7) +1,instr(tab.DSCRITIC,'#',1,8)-instr(tab.DSCRITIC,'#',1,7)-1) dsdrisco,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,8) +1,instr(tab.DSCRITIC,'#',1,9)-instr(tab.DSCRITIC,'#',1,8)-1) innivris,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,9) +1,instr(tab.DSCRITIC,'#',1,10)-instr(tab.DSCRITIC,'#',1,9)-1) dsdrisgp,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,10) +1,instr(tab.DSCRITIC,'#',1,11)-instr(tab.DSCRITIC,'#',1,10)-1) inpessoa,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,11) +1,instr(tab.DSCRITIC,'#',1,12)-instr(tab.DSCRITIC,'#',1,11)-1) cdagenci,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,12) +1,instr(tab.DSCRITIC,'#',1,13)-instr(tab.DSCRITIC,'#',1,12)-1) innivrge,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,13) +1,instr(tab.DSCRITIC,'#',1,14)-instr(tab.DSCRITIC,'#',1,13)-1) dtrefere,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,14) +1,instr(tab.DSCRITIC,'#',1,15)-instr(tab.DSCRITIC,'#',1,14)-1) dtmvtolt,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,15) +1,instr(tab.DSCRITIC,'#',1,16)-instr(tab.DSCRITIC,'#',1,15)-1) vlendivi,              
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,16) +1,instr(tab.DSCRITIC,'#',1,17)-instr(tab.DSCRITIC,'#',1,16)-1) vlendigp,
              substr(tab.DSCRITIC,instr(tab.DSCRITIC,'#',1,17) +1,instr(tab.DSCRITIC,'#',1,18)-instr(tab.DSCRITIC,'#',1,17)-1) vr_indice
         from (select wrk.DSCRITIC 
                 from tbgen_batch_relatorio_wrk wrk
                where wrk.cdcooper    = pr_cdcooper
                  and wrk.cdprograma  = 'pc_crps634_i'
                  and wrk.dsrelatorio = 'rptGrupoEconomico'
                  --and wrk.dtmvtolt    = pr_dtmvtolt
               ) tab;
       BEGIN
         BEGIN
           FOR r_crapgrupo IN c_crapgrupo  
           LOOP
               --Criar registro na crapgrp
               vr_tab_crapgrp(r_crapgrupo.vr_indice).cdcooper := r_crapgrupo.cdcooper;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).nrdgrupo := r_crapgrupo.nrdgrupo;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).nrctasoc := r_crapgrupo.nrctasoc;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).nrdconta := r_crapgrupo.nrdconta;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).idseqttl := r_crapgrupo.idseqttl;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).nrcpfcgc := r_crapgrupo.nrcpfcgc;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).dsdrisco := r_crapgrupo.dsdrisco;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).innivris := r_crapgrupo.innivris;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).dsdrisgp := r_crapgrupo.dsdrisgp;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).inpessoa := r_crapgrupo.inpessoa;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).cdagenci := r_crapgrupo.cdagenci;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).innivrge := r_crapgrupo.innivrge;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).dtrefere := r_crapgrupo.dtrefere;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).dtmvtolt := r_crapgrupo.dtmvtolt;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).vlendivi := r_crapgrupo.vlendivi;
               vr_tab_crapgrp(r_crapgrupo.vr_indice).vlendigp := r_crapgrupo.vlendigp;             
               
           END LOOP;
         EXCEPTION
           WHEN OTHERS THEN
              pr_des_erro:= 'Erro pc_carrega_tabgrupo: '||sqlerrm;
         END;
       END pc_carrega_tabgrupo;          

  BEGIN
    
 
    -- Nome do programa
    vr_cdprogra := 'CRPS634_I';
    
    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS643_I',
                               pr_action => vr_cdprogra);

    -- Verificar dados da cooperativa
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Verifica se a tupla retorno registro, senão gera crítica 
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      pr_cdcritic := 651;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);

      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || pr_dscritic);

      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Limpar crítica
    pr_dscritic := '';                               
                               
    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => pr_cdcritic);
    -- Se retornou algum erro
    if pr_cdcritic <> 0 then
      -- Buscar descrição do erro
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      -- Envio centralizado de log de erro
      raise vr_exc_erro;
    end if;
    
      -- Para os programas em paralelo devemos buscar o array crapdat.
      -- Leitura do calendário da cooperativa
      IF pr_tab_crapdat.dtmvtolt IS NULL THEN
        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat
          INTO pr_tab_crapdat;
        CLOSE btch0001.cr_crapdat;
      END IF;    
      
    -- Buscar a data do movimento
    open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor pois haverá raise
      close btch0001.cr_crapdat;
      pr_cdcritic:= 1;
      -- Montar mensagem de critica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      raise vr_exc_erro;
    else
      -- Atribuir a proxima data do movimento
      vr_dtmvtopr := rw_crapdat.dtmvtopr;
      -- Atribuir o indicador de processo
      vr_inproces := rw_crapdat.inproces;
    end if;
    close btch0001.cr_crapdat;      
    
    -- Atribuição de valores iniciais da procedure
    vr_nmformul := '';
    vr_nrcopias := 1;

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    -- Nome do arquivo
    vr_nmarquiv := 'crrl628';
    
    -- Buscar quantidade parametrizada de Jobs
    vr_qtdjobs := gene0001.fn_retorna_qt_paralelo( pr_cdcooper  --pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                                   ,vr_cdprogra --pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Código do programa
                                                  ); 
                                                  
                          
    
    /* Paralelismo visando performance Rodar Somente no processo Noturno (testa se é a primeira vez)*/
    -- executor principal do job paralelismo
    IF vr_inproces        > 2 AND 
      vr_qtdjobs          > 0 and 
      pr_cdagenci         = 0 then  
    
       --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'I',    
                      pr_cdprograma => vr_cdprogra,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => 1,-- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger);
                      
        -- Gerar o ID para o paralelismo
        vr_idparale := gene0001.fn_gera_ID_paralelo;
        
        -- Se houver algum erro, o id vira zerado
        IF vr_idparale = 0 THEN
           -- Levantar exceção
           vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
           RAISE vr_exc_saida;
        END IF;
                                              
        -- Verifica se algum job paralelo executou com erro
        vr_qterro := 0;
        vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                      pr_cdprogra    => vr_cdprogra,
                                                      pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                      pr_tpagrupador => 1,
                                                      pr_nrexecucao  => 1);   
         IF vr_inproces = 0 THEN
            -- limpa tabela de grupo.
            DELETE FROM crapgrp cp WHERE cp.cdcooper = pr_cdcooper;
            COMMIT;           
         END IF;
              
                 
            pc_log_programa(PR_DSTIPLOG      => 'O',
            PR_CDPROGRAMA         => pr_cdprogra ,
            pr_cdcooper           => pr_cdcooper,
            pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
            pr_tpocorrencia       => 4,
            pr_dsmensagem         => 'Limpou crapgrp ',
            PR_IDPRGLOG           => vr_idlog_ini_ger);                                               
                                                            
          
                                                      
      -- Agências de empresas com ações societárias em outras empresas para formação do grupo econômico
      for rw_crapepa_age in cr_crapepa_age (pr_cdcooper,vr_qterro,rw_crapdat.dtmvtolt) loop
                                            
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := vr_cdprogra ||'_'|| rw_crapepa_age.cdagenci || '$';  
      
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_crapepa_age.cdagenci,3,'0') --> Utiliza a agência como id programa
                                  ,pr_des_erro => vr_dscritic);
                                  
        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;     
        
        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração dos dados
        -- para a agência atual atraves de Job no banco
                      
        vr_dsplsql := 'DECLARE' || chr(13) || 
        '  wpr_stprogra NUMBER;' || chr(13) || 
        '  wpr_infimsol NUMBER;' || chr(13) || 
        '  wpr_cdcritic NUMBER;' || chr(13) || 
        '  wpr_dscritic VARCHAR2(1500);' || chr(13) || 
        '  rw_crapdat btch0001.rw_crapdat%TYPE;' || chr(13) || 
        'BEGIN' || chr(13) || 
        'cecred.pc_crps634_i( '|| pr_cdcooper || ',' ||
                           rw_crapepa_age.cdagenci || ',' ||
                           nvl(pr_cdoperad,0) || ',' ||
                           '''' || pr_cdprogra || '''' || ',' ||
                           replace(pr_persocio,',','.') || ',' ||
                           'rw_crapdat'|| ',' ||
                           ''''||pr_impcab ||''''   || ',' ||
                           vr_idparale || ',' ||
                           ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' ||
        chr(13) || 
        'END;';                         
                  
                      
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                               ,pr_cdprogra => vr_cdprogra  --> Código do programa
                               ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                               ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                               ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                               ,pr_jobname  => vr_jobname   --> Nome randomico criado
                               ,pr_des_erro => vr_dscritic);    
                               
         -- Testar saida com erro
         if vr_dscritic is not null then 
           -- Grava LOG de ocorrência final do cursor cr_craprpp
           pc_log_programa(PR_DSTIPLOG      => 'O',
                      PR_CDPROGRAMA         => pr_cdprogra ||'_'|| rw_crapepa_age.cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Erro submit job: '|| vr_dscritic,
                      PR_IDPRGLOG           => vr_idlog_ini_ger);     
            -- Levantar exceçao
            raise vr_exc_saida;
            
         end if;
                                                        
         -- Chama rotina que irá pausar este processo controlador
         -- caso tenhamos excedido a quantidade de JOBS em execuçao
         gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                     ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                     ,pr_des_erro => vr_dscritic);

         -- Testar saida com erro
         if  vr_dscritic is not null then 
           -- Levantar exceçao
           raise vr_exc_saida;
         end if;
         
      end loop;        
      
      --dbms_output.put_line('Inicio pc_aguarda_paralelo GERAL - '||to_char(sysdate,'hh24:mi:ss')); 
      -- Chama rotina de aguardo agora passando 0, para esperarmos
      -- até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => 0
                                  ,pr_des_erro => vr_dscritic); 
                                  
      -- Testar saida com erro
      if  vr_dscritic is not null then 
        -- Levantar exceçao
        raise vr_exc_saida;
      end if; 
      

      -- Verifica se algum job executou com erro
      vr_qterro := 0;
      vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                    pr_cdprogra    => vr_cdprogra,
                                                    pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                    pr_tpagrupador => 1,
                                                    pr_nrexecucao  => 1);
      if vr_qterro > 0 then 
        vr_cdcritic := 0;
        vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
        raise vr_exc_saida;
      end if;                                  
   
   END IF;
   
   IF vr_qtdjobs =  0 and 
      pr_cdagenci =  0 then    
            -- limpa tabela de grupo.
            DELETE FROM crapgrp cp WHERE cp.cdcooper = pr_cdcooper;
            COMMIT; 
   
            pc_log_programa(PR_DSTIPLOG      => 'O',
            PR_CDPROGRAMA         => pr_cdprogra ,
            pr_cdcooper           => pr_cdcooper,
            pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
            pr_tpocorrencia       => 4,
            pr_dsmensagem         => 'Limpou crapgrp ',
            PR_IDPRGLOG           => vr_idlog_ini_ger);                                               
   
   END IF;
   
   -- execução dos jobs criados dinamicamente
   IF vr_inproces  > 2 AND 
      vr_qtdjobs   > 0 and 
      pr_cdagenci  > 0 then  
     
       if pr_cdagenci <> 0 then
          vr_tpexecucao := 2;
        else
          vr_tpexecucao := 1;
        end if;    
       
        -- Grava controle de batch por agência
        gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                        ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                        ,pr_dtmvtolt    => rw_crapdat.dtmvtolt       -- Data de Movimento
                                        ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                        ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                        ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                        ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                        ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                        ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                        ,pr_dscritic    => vr_dscritic);   
        -- Testar saida com erro
        if  vr_dscritic is not null then 
          -- Levantar exceçao
          raise vr_exc_saida;
        end if;    
        
        --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'I',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par);

  
   END IF; -- Execução dos jobs montados dinamicamente (controle de início de jobs)
    
     -- execução com ou sem paralelismo.
     IF (vr_qtdjobs   = 0 AND pr_cdagenci  = 0) OR    
        (vr_qtdjobs   > 0 AND pr_cdagenci  > 0) THEN  
        -- Gerar grupos economicos
        -- Grava LOG de ocorrência inicial do cursor cr_craprpp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                          PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                          pr_tpocorrencia       => 4,
                          pr_dsmensagem         => 'Inicio Montar Grupo Econômico ' || to_char(sysdate,'hh24:mi:ss') || ' Coperativa ' || pr_cdcooper || ' Agencia: ' ||pr_cdagenci||' - INPROCES: '||vr_inproces,
                          PR_IDPRGLOG           => vr_idlog_ini_par); 
     
        geco0001.pc_forma_grupo_economico(pr_cdcooper    => pr_cdcooper
                                          ,pr_cdagenci    => pr_cdagenci
                                          ,pr_nrdcaixa    => 0
                                          ,pr_cdoperad    => pr_cdoperad
                                          ,pr_cdprogra    => LOWER(pr_cdprogra)
                                          ,pr_idorigem    => 1
                                          ,pr_persocio    => pr_persocio
                                          ,pr_tab_crapdat => pr_tab_crapdat
                                          ,pr_tab_grupo   => vr_tab_crapgrp
                                          ,pr_cdcritic    => pr_cdcritic
                                          ,pr_dscritic    => pr_dscritic);
                                     
       -- Verifica se ocorreram erros
       IF pr_dscritic <> 'OK' THEN
        -- Verifica se a tabela de formação de grupos retornou sem registros
        IF vr_tab_crapgrp.count = 0 THEN
          pr_dscritic := pr_dscritic || ' Nao foi possivel realizar a formacao do grupo economico para a ' || rw_crapcop.nmrescop;
          
          pc_log_programa(PR_DSTIPLOG           => 'O',
                PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                pr_cdcooper           => pr_cdcooper,
                pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                pr_tpocorrencia       => 4,
                pr_dsmensagem         => 'GRUPO RETORNOU ZERADO',
                PR_IDPRGLOG           => vr_idlog_ini_par);      
          
        END IF;

        -- Gravar mensagem de erro em LOG
        btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                                   pr_ind_tipo_log  => 2, -- Erro tratato
                                   pr_nmarqlog      => vr_cdprogra,
                                   pr_des_log       => to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || pr_dscritic);

        RAISE vr_exc_erro;
       END IF;                                     
       
       -- Fim grupo econômico                              
       pc_log_programa(PR_DSTIPLOG           => 'O',
                PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                pr_cdcooper           => pr_cdcooper,
                pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                pr_tpocorrencia       => 4,
                pr_dsmensagem         => 'Fim Montar Grupo Econônico ' || to_char(sysdate,'hh24:mi:ss') || ' Coperativa ' ||pr_cdcooper || ' Agencia: ' ||pr_cdagenci||' - INPROCES: '||vr_inproces || ' Registros ' ||vr_tab_crapgrp.count,
                PR_IDPRGLOG           => vr_idlog_ini_par);                                          

        
        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                  pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                  pr_cdcooper   => pr_cdcooper, 
                  pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                  pr_idprglog   => vr_idlog_ini_par,
                  pr_flgsucesso => 1); 

     END IF;
   
   -- executor principal do job 
   /*IF vr_inproces  > 2 AND 
      vr_qtdjobs   > 0 and 
      pr_cdagenci  = 0 then  
   
   -- Inicio carregar tabela memória  vr_tab_crapgrp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                  PR_CDPROGRAMA         => pr_cdprogra || '$',
                  pr_cdcooper           => pr_cdcooper,
                  pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                  pr_tpocorrencia       => 4,
                  pr_dsmensagem         => 'carrega da wrk para memória  vr_tab_crapgrp -> ' || to_char(sysdate,'hh24:mi:ss'),
                  PR_IDPRGLOG           => vr_idlog_ini_par);                      

         -- carrega tabela memória.
			   pc_carrega_tabgrupo (pr_cdcooper => pr_cdcooper,
                           pr_dtmvtolt =>  rw_crapdat.dtmvtolt,
                           pr_des_erro =>  vr_dscritic);
         
            --Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
               --Levantar Exceção
               RAISE vr_exc_saida;
            END IF;                                                  
         
        -- Fim carregar tabela memória  vr_tab_crapgrp
        pc_log_programa(PR_DSTIPLOG           => 'O',
                  PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                  pr_cdcooper           => pr_cdcooper,
                  pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                  pr_tpocorrencia       => 4,
                  pr_dsmensagem         => 'Fim carregar tabela memória  vr_tab_crapgrp ' || vr_tab_crapgrp.COUNT || ' - ' || to_char(sysdate,'hh24:mi:ss'),
                  PR_IDPRGLOG           => vr_idlog_ini_par); 
 
   END IF;    */                              
   
   -- executa com ou sem paralelismo.
   IF (vr_qtdjobs   = 0 AND pr_cdagenci  = 0) OR 
      (vr_qtdjobs   > 0 AND pr_cdagenci  = 0) THEN  

      -- grava tab temporária   tbgen_batch_relatorio_wrk 
          pc_log_programa(PR_DSTIPLOG           => 'O',
                  PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                  pr_cdcooper           => pr_cdcooper,
                  pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                  pr_tpocorrencia       => 4,
                  pr_dsmensagem         => 'gravar temporária wrk ' || vr_tab_crapgrp.COUNT || ' - ' || to_char(sysdate,'hh24:mi:ss'),
                  PR_IDPRGLOG           => vr_idlog_ini_par);   
                  
        
        vr_index := vr_tab_crapgrp.FIRST;
        LOOP
          EXIT WHEN vr_index IS NULL;

               vr_ds_xml := ds_character_separador||
               vr_tab_crapgrp(vr_index).cdcooper||ds_character_separador||
               vr_tab_crapgrp(vr_index).nrdgrupo||ds_character_separador||
               vr_tab_crapgrp(vr_index).nrctasoc||ds_character_separador||
               vr_tab_crapgrp(vr_index).nrdconta||ds_character_separador||
               vr_tab_crapgrp(vr_index).idseqttl||ds_character_separador||
               vr_tab_crapgrp(vr_index).nrcpfcgc||ds_character_separador||
               vr_tab_crapgrp(vr_index).dsdrisco||ds_character_separador||
               vr_tab_crapgrp(vr_index).innivris||ds_character_separador||
               vr_tab_crapgrp(vr_index).dsdrisgp||ds_character_separador||
               vr_tab_crapgrp(vr_index).inpessoa||ds_character_separador||
               vr_tab_crapgrp(vr_index).cdagenci||ds_character_separador||
               vr_tab_crapgrp(vr_index).innivrge||ds_character_separador||
               vr_tab_crapgrp(vr_index).dtrefere||ds_character_separador||
               vr_tab_crapgrp(vr_index).dtmvtolt||ds_character_separador||
               vr_tab_crapgrp(vr_index).vlendivi||ds_character_separador||
               vr_tab_crapgrp(vr_index).vlendigp||ds_character_separador||
               vr_index||ds_character_separador;
                                         
               insert into tbgen_batch_relatorio_wrk(CDCOOPER
                                       ,CDPROGRAMA
                                       ,DSRELATORIO
                                       ,DTMVTOLT
                                       ,CDAGENCI
                                       ,NRDCONTA
                                       ,DSCRITIC) 
                                       values 
                                       (pr_cdcooper
                                       ,'pc_crps634_i'
                                       ,'rptGrupoEconomico'
                                       ,pr_tab_crapdat.dtmvtolt
                                       ,vr_tab_crapgrp(vr_index).cdagenci
                                       ,vr_tab_crapgrp(vr_index).nrdconta
                                       ,vr_ds_xml);            
                                       COMMIT;
            vr_index := vr_tab_crapgrp.NEXT(vr_index);
        END LOOP;                  
        
        -- Fim tab temporária   tbgen_batch_relatorio_wrk 
        
        pc_log_programa(PR_DSTIPLOG           => 'O',
                  PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                  pr_cdcooper           => pr_cdcooper,
                  pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                  pr_tpocorrencia       => 4,
                  pr_dsmensagem         => 'Termintou Temporária wrk ' || vr_tab_crapgrp.COUNT || ' - ' || to_char(sysdate,'hh24:mi:ss'),
                  PR_IDPRGLOG           => vr_idlog_ini_par);


       pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Mesclar Grupo Inicio ' ||pr_cdcooper  || ' - ' || to_char(sysdate,'hh24:mi:ss'),
                      PR_IDPRGLOG           => vr_idlog_ini_par);  
      -- Mesclar grupos
                               
      geco0001.pc_mesclar_grupos(pr_cdcooper => pr_cdcooper
                                ,pr_nrdgrupo => 0
                                ,pr_des_erro => pr_dscritic);

      -- Verifica se ocorreram erros
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Mesclar Grupo Fim '  ||pr_cdcooper  || ' - ' || to_char(sysdate,'hh24:mi:ss'),
                      PR_IDPRGLOG           => vr_idlog_ini_par);  
    
   
         pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Inicio calculo risco endividamento grupo ' ||pr_cdcooper  || ' - ' || to_char(sysdate,'hh24:mi:ss') ,
                      PR_IDPRGLOG           => vr_idlog_ini_par);  
                      
      -- Processar grupos para cálculo de risco
      FOR rw_crapgrpb IN cr_crapgrpb(pr_cdcooper) LOOP
        -- Verifica se é o primeiro registro do grupo
        IF rw_crapgrpb.nrdgrupo <> rw_crapgrpb.nrdgrupoa THEN
      -- Calcular endividamento do grupo
          geco0001.pc_calc_endivid_risco_grupo(pr_cdcooper    => pr_cdcooper
                                     ,pr_cdagenci    => pr_cdagenci
                                     ,pr_nrdcaixa    => pr_nrdcaixa
                                     ,pr_cdoperad    => pr_cdoperad
                                     ,pr_cdprogra    => pr_cdprogra
                                     ,pr_idorigem    => 1
                                     ,pr_nrdgrupo    => rw_crapgrpb.nrdgrupo
                                     ,pr_tpdecons    => TRUE
                                     ,pr_tab_crapdat => pr_tab_crapdat
                                     ,pr_tab_grupo   => vr_tab_crapgrp
                                     ,pr_dstextab    => vr_dstextab
                                     ,pr_dsdrisco    => opt_dsdrisco
                                     ,pr_vlendivi    => opt_vlendivi
                                     ,pr_des_erro    => pr_dscritic);
        END IF;
      END LOOP;
  
           pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Fim calculo risco endividamento grupo ' ||pr_cdcooper  || ' - ' || to_char(sysdate,'hh24:mi:ss') ,
                      PR_IDPRGLOG           => vr_idlog_ini_par);
      
        pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Eliminar registros marcadores da PL Table -> ' || vr_tab_crapgrp.COUNT || ' linhas ' || pr_cdcooper || ' Agencia: ' ||pr_cdagenci||' - INPROCES: '||vr_inproces,
                      PR_IDPRGLOG           => vr_idlog_ini_par);  
                             

       -- Eliminar registros marcadores da PL Table
        vr_index := vr_tab_crapgrp.FIRST;
        LOOP
          EXIT WHEN vr_index IS NULL;
          vr_indexd := vr_index;
          vr_index := vr_tab_crapgrp.NEXT(vr_index);

          IF vr_tab_crapgrp(vr_indexd).nrdgrupo IS NULL AND vr_tab_crapgrp(vr_indexd).nrdconta IS NULL AND vr_tab_crapgrp(vr_indexd).cdagenci IS NULL THEN
            vr_tab_crapgrp.DELETE(vr_indexd);
          END IF;
        END LOOP;
        
        pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Eliminar registros marcadores da PL Table Concluido ' || pr_cdcooper || ' Agencia: ' ||pr_cdagenci||' - INPROCES: '||vr_inproces,
                      PR_IDPRGLOG           => vr_idlog_ini_par);  
  
   
        -- Montar xml e relatório
        pc_log_programa(PR_DSTIPLOG           => 'O',
                  PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                  pr_cdcooper           => pr_cdcooper,
                  pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                  pr_tpocorrencia       => 4,
                  pr_dsmensagem         => 'Início montar xml e rpt ' || vr_tab_crapgrp.COUNT,
                  PR_IDPRGLOG           => vr_idlog_ini_par);   
    -- Inicializar CLOB para XML
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

    -- Percorrer PL Table para formar relatório
    vr_index := vr_tab_crapgrp.first;
    vr_xmlbuffer := '<?xml version="1.0" encoding="utf-8"?><coope>';

    LOOP
      EXIT WHEN vr_index IS NULL;

      -- Verifica se as cooperativas estão corretas
      IF vr_tab_crapgrp(vr_index).cdcooper = rw_crapcop.cdcooper THEN
        vr_controle := TRUE;

        -- Criar nodo pai
        IF vr_tab_crapgrp.PRIOR(vr_index) IS NOT NULL THEN
          IF vr_tab_crapgrp(vr_index).nrdgrupo <> vr_tab_crapgrp(vr_tab_crapgrp.PRIOR(vr_index)).nrdgrupo THEN
            vr_xmlbuffer := vr_xmlbuffer || '<grupo nr="' || vr_tab_crapgrp(vr_index).nrdgrupo || '">';
          END IF;
        ELSE
          vr_xmlbuffer := vr_xmlbuffer || '<grupo nr="' || vr_tab_crapgrp(vr_index).nrdgrupo || '">';
        END IF;

        vr_xmlbuffer := vr_xmlbuffer || '<registro><cdagenci>' || vr_tab_crapgrp(vr_index).cdagenci || '</cdagenci>' ||
                                        '<nrdgrupo>' || TO_CHAR(vr_tab_crapgrp(vr_index).nrdgrupo, 'FM999G999G990') || '</nrdgrupo>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer, pr_gravfim => FALSE, pr_clob => vr_xml);
        vr_xmlbuffer := vr_xmlbuffer || '<nrctasoc>' || TO_CHAR(vr_tab_crapgrp(vr_index).nrctasoc, 'FM9999G9999G999G9') || '</nrctasoc>' ||
                                        '<dsdrisco>' || vr_tab_crapgrp(vr_index).dsdrisco || '</dsdrisco>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer, pr_gravfim => FALSE, pr_clob => vr_xml);
        vr_xmlbuffer := vr_xmlbuffer || '<vlendivi>' || TO_CHAR(Nvl(vr_tab_crapgrp(vr_index).vlendivi, '0'), 'FM999G999G990D00') || '</vlendivi>' ||
                                        '<dsdrisgp>' || vr_tab_crapgrp(vr_index).dsdrisgp || '</dsdrisgp>' ||
                                        '<vlendigp>' || TO_CHAR(Nvl(vr_tab_crapgrp(vr_index).vlendigp, '0'), 'FM999G999G990D00') || '</vlendigp></registro>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer, pr_gravfim => FALSE, pr_clob => vr_xml);
      END IF;

      -- Fechar nodo pai
      IF vr_tab_crapgrp.NEXT(vr_index) IS NOT NULL THEN
        IF vr_tab_crapgrp(vr_index).nrdgrupo <> vr_tab_crapgrp(vr_tab_crapgrp.NEXT(vr_index)).nrdgrupo THEN
          vr_xmlbuffer := vr_xmlbuffer || '</grupo>';
        END IF;
      ELSE
        vr_xmlbuffer := vr_xmlbuffer || '</grupo>';
      END IF;

      -- Gerar próximo índice
      IF (vr_tab_crapgrp.next(vr_index) IS NOT NULL AND (vr_tab_crapgrp(vr_index).cdcooper = vr_tab_crapgrp(vr_tab_crapgrp.next(vr_index)).cdcooper AND
          vr_controle = TRUE)) OR vr_controle = FALSE THEN
        vr_index := vr_tab_crapgrp.next(vr_index);
      ELSE
        vr_index := NULL;
      END IF;
    END LOOP;

    -- Finalizar TAG XML
    vr_xmlbuffer := vr_xmlbuffer || '</coope>';
    gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer, pr_gravfim => TRUE, pr_clob => vr_xml);

    -- Gerar arquivo para internet
    gene0002.pc_gera_arquivo_intranet(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => 0
                                     ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt
                                     ,pr_nmarqimp => vr_nom_dir || '/' || vr_nmarquiv
                                     ,pr_nmformul => '132col'
                                     ,pr_dscritic => pr_cdcritic
                                     ,pr_tab_erro => vr_tab_craterr
                                     ,pr_des_erro => pr_dscritic);

    -- Verifica se ocorreram erros
    IF pr_dscritic <> 'OK' THEN
      IF vr_tab_craterr.count = 0 THEN
        pr_dscritic := 'Nao foi possivel gerar o arquivo para a intranet - ' || rw_crapcop.nmrescop;
      ELSE
        pr_dscritic := vr_tab_craterr(vr_tab_craterr.first).dscritic || ' - ' || rw_crapcop.nmrescop;
      END IF;

      -- Gravar mensagem de erro em LOG
      btch0001.pc_gera_log_batch(pr_cdcooper        => pr_cdcooper,
                                 pr_ind_tipo_log  => 2,
                                 pr_nmarqlog      => vr_cdprogra,
                                 pr_des_log       => to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> ' || pr_dscritic);
    ELSE
      pr_dscritic := NULL;
    END IF;

    -- Criar arquivo princial com dados armazenados
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => pr_cdprogra
                               ,pr_dtmvtolt  => pr_tab_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_xml
                               ,pr_dsxmlnode => '/coope/grupo'
                               ,pr_dsjasper  => 'crrl628.jasper'
                               ,pr_dsparams  => 'PR_IMPCAB##' || pr_impcab
                               ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarquiv || '.lst'
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 132
                               ,pr_cdrelato  => 628
                               ,pr_flg_impri => 'S'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => vr_nrcopias
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'N'
                               ,pr_des_erro  => pr_dscritic);

    -- Verificar se ocorreram erros
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Finalizar XML
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);


       -- Montar xml e relatório
        pc_log_programa(PR_DSTIPLOG           => 'O',
                  PR_CDPROGRAMA         => pr_cdprogra ||'_'|| pr_cdagenci || '$',
                  pr_cdcooper           => pr_cdcooper,
                  pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                  pr_tpocorrencia       => 4,
                  pr_dsmensagem         => 'Fim montar xml e rpt ' || vr_tab_crapgrp.COUNT,
                  PR_IDPRGLOG           => vr_idlog_ini_par);   

   
    -- Gerar mensagem no LOG indicando sucesso
    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper,
                               pr_ind_tipo_log  => 1,
                               pr_nmarqlog      => vr_cdprogra,
                               pr_des_log       => to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> Grupo Economico formado com sucesso.');
    
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_stprogra => pr_stprogra);

    if vr_idcontrole <> 0 then
      -- Atualiza finalização do batch na tabela de controle 
      gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                                         ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                                         ,pr_dscritic   => vr_dscritic);
                                         
      -- Testar saida com erro
      if  vr_dscritic is not null then 
        -- Levantar exceçao
        raise vr_exc_saida;
      end if; 
                                                      
    end if; 
 
      --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F',    
                      pr_cdprograma => vr_cdprogra,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger,
                      pr_flgsucesso => 1);                 

    --Salvar informacoes no banco de dados
    commit;
  else
  
    -- Atualiza finalização do batch na tabela de controle 
    gene0001.pc_finaliza_batch_controle(vr_idcontrole   --pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                       ,pr_cdcritic     --pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                       ,pr_dscritic     --pr_dscritic  OUT crapcri.dscritic%TYPE
                                       );  

    -- Encerrar o job do processamento paralelo dessa agência
    gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                ,pr_des_erro => vr_dscritic);  
                                
                                
  
    --Salvar informacoes no banco de dados
    commit;
  end if;
  --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Efetuar rollback
      ROLLBACK;
      
      
      
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas codigo
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descricao
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      
      -- Devolvemos codigo e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      IF nvl(pr_idparale,0) <> 0 THEN

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);                                     
        
        -- Grava LOG de erro com as críticas retornadas                           
        pc_log_programa(pr_dstiplog      => 'E', 
                        pr_cdprograma    => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper      => pr_cdcooper,
                        pr_tpexecucao    => vr_tpexecucao,
                        pr_tpocorrencia  => 3,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => pr_cdcritic,
                        pr_dsmensagem    => pr_dscritic,
                        pr_flgsucesso    => 0,
                        pr_idprglog      => vr_idlog_ini_par);  
                        
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);                        
                                    
      ELSE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
         --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
        pc_log_programa(pr_dstiplog   => 'F',    
                      pr_cdprograma => vr_cdprogra,           
                      pr_cdcooper   => pr_cdcooper, 
                      pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_ger,
                      pr_flgsucesso => 1);                                                   
                                                     
        END IF;
      END IF;
      -- Efetuar rollback
      ROLLBACK;
      
      
    WHEN others THEN
      -- Efetuar rollback
      ROLLBACK;

      -- Propagar crítica
      pr_cdcritic := 0;
      pr_dscritic := 'Erro: ' || SQLERRM;

      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 3 -- Erro crítico
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra || ' --> ' || pr_dscritic);
      
      IF nvl(pr_idparale,0) <> 0 THEN

        --Grava data fim para o JOB na tabela de LOG 
        pc_log_programa(pr_dstiplog   => 'F',    
                        pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,           
                        pr_cdcooper   => pr_cdcooper, 
                        pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                        pr_idprglog   => vr_idlog_ini_par,
                        pr_flgsucesso => 0);                                     
        
        -- Grava LOG de erro com as críticas retornadas                           
        pc_log_programa(pr_dstiplog      => 'E', 
                        pr_cdprograma    => vr_cdprogra||'_'||pr_cdagenci,
                        pr_cdcooper      => pr_cdcooper,
                        pr_tpexecucao    => vr_tpexecucao,
                        pr_tpocorrencia  => 3,
                        pr_cdcriticidade => 1,
                        pr_cdmensagem    => pr_cdcritic,
                        pr_dsmensagem    => pr_dscritic,
                        pr_flgsucesso    => 0,
                        pr_idprglog      => vr_idlog_ini_par);  
                        
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                    ,pr_des_erro => vr_dscritic);                        
                                    
      ELSE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
      END IF;
                                      
  END;
END PC_CRPS634_I;
/
