CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS707 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                               ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                               ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                               ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                               ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
BEGIN

   /* .............................................................................

   Programa: pc_crps707
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro Guaranha - RKAM
   Data    : Setembro/2016                        Ultima atualizacao: 08/06/2018

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Realizado a efetivação de agendamentos de TEDs Sicredi

   Alteracoes: 01/11/2016 - Ajustes realizados para corrigir os problemas encontrados
							              durante a homologação da área de negócio
							             (Adriano - M211).

	             24/11/2016 - Ajuste para alimentar correta o lote utilizado no 
							              lançamento de créditos na conta do cooperado
							              (Adriano - SD 563707).

               01/12/2016 - Ajuste para incluir mais informações no e-mail de rejeições
                            (Adriano - SD 568539).             

               12/01/2017 - Ajuste para verificar se cooperado é migrado 
                            (Adriano - SD 592406).

               17/05/2017 - Ajuste para não incluir a validação "3 - Ausencia ou Divergencia na Indicacao do CPF/CNPJ"
                            no proc_message
                            (Ana - SD 660364 / 663299).

               25/05/2017 - Ajuste para incluir a validação "3 - Ausencia ou Divergencia na Indicacao do CPF/CNPJ"
                            no proc_message, porém, substituir o tempo "ERRO" por "ALERTA".
                            Alteradas mais algumas mensagens para considerar Alerta e não Erro
                            (Ana - SD 660364 / 663299).
                            
			   27/06/2017 - Ajustes para atender as mudanças do catalago de TED - SPB
			                (Adriano - SD 698655).
                      
			   26/07/2017 - #713816 Ajustes para garantir o fechamento do arquivo para que o move
			                do mesmo ocorra (Carlos)
                      
			   08/08/2017 - Ajuste para não fechar o arquivo quando for encontrado inconsistências em algum 
			                registro, pois o arquivo todo deve ser processado e os registros com problema serão
			                encaminhaoos via e-mail para a área responsável tomar as devidas providências junto ao SICREDI
			                (Adriano).
                      
			   06/06/2018 - PRJ450 - Regulatorios de Credito - Centralizacao do lancamento em conta corrente (Fabiano B. Dias - AMcom). 
			   
   ............................................................................. */

   DECLARE

     -- Selecionar os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
     SELECT cop.cdcooper
           ,cop.nmrescop
           ,cop.nrtelura
           ,cop.cdbcoctl
           ,cop.cdagectl
           ,cop.dsdircop
           ,cop.nrctactl
     FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE;

     --Registro do tipo calendario
     rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

     -- Verificar se o arquivo já não foi processado (existe na tabela)
     CURSOR cr_nmarquiv(pr_nmarquiv VARCHAR2) IS
     SELECT 1
       FROM tbted_control_arq arq
      WHERE lower(arq.nmarquiv) = lower(pr_nmarquiv);
     vr_flgexis NUMBER;

     -- Verificar ultima sequencia processada
     CURSOR cr_sqarquiv(pr_dtrefere DATE
                       ,pr_nrseqarq NUMBER) IS
     SELECT 1
       FROM tbted_control_arq arq
      WHERE arq.dtrefere = pr_dtrefere
        AND arq.nrseqarq = pr_nrseqarq;

     -- Busca do Cooperado pelo CPF
     CURSOR cr_crapass(pr_nrcpfcgc NUMBER) IS
     SELECT cdcooper
           ,nrdconta
           ,dtdemiss
           ,nmprimtl
       FROM crapass
      WHERE nrcpfcgc = pr_nrcpfcgc;
     rw_crapass cr_crapass%ROWTYPE; 
    
     -- Busca do Cooperado pelo CPF
     CURSOR cr_crapass2(pr_nrdconta crapass.nrdconta%TYPE
                       ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
     SELECT cdcooper
           ,nrdconta
           ,dtdemiss
           ,nmprimtl
       FROM crapass
      WHERE nrdconta = pr_nrdconta
        AND nrcpfcgc = pr_nrcpfcgc;
     rw_crapass2 cr_crapass2%ROWTYPE; 
   
     -- Busca do Cooperado por cooperativa e conta
     CURSOR cr_crapass3(pr_cdcooper crapass.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
     SELECT cdcooper
           ,nrdconta             
           ,dtdemiss
           ,nmprimtl
     FROM crapass
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta;
     rw_crapass3 cr_crapass3%ROWTYPE; 
   
     -- Busca do Cooperado pelo CPF e que não seja primeiro titular
     CURSOR cr_crapttl(pr_nrcpfcgc NUMBER) IS
     SELECT ttl.cdcooper
           ,ttl.nrdconta 
       FROM crapttl ttl
      WHERE ttl.nrcpfcgc = pr_nrcpfcgc
        AND ttl.idseqttl > 1;
     rw_crapttl cr_crapttl%ROWTYPE; 
     
     -- Busca do Cooperado pelo CPF e que não seja primeiro titular
     CURSOR cr_crapttl2(pr_nrcpfcgc crapttl.nrcpfcgc%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE) IS
     SELECT ttl.cdcooper
           ,ttl.nrdconta 
       FROM crapttl ttl
      WHERE ttl.nrcpfcgc = pr_nrcpfcgc
        AND ttl.nrdconta = pr_nrdconta;
     rw_crapttl2 cr_crapttl2%ROWTYPE; 
        
     -- Buscar Lote
     CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                       ,pr_nrdolote IN craptab.dstextab%TYPE) IS
     SELECT nrseqdig,
            qtinfoln,
            qtcompln,
            vlinfodb,
            vlcompdb,
            ROWID
        FROM craplot
       WHERE craplot.cdcooper = pr_cdcooper
         AND craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdagenci = 1
         AND craplot.cdbccxlt = 100
         AND craplot.nrdolote = pr_nrdolote;
     rw_craplot cr_craplot%ROWTYPE;

     CURSOR cr_craptco(pr_cdcopant IN craptco.cdcopant%TYPE
                      ,pr_nrctaant IN craptco.nrctaant%TYPE)IS
     SELECT craptco.cdcooper
           ,craptco.nrdconta
       FROM craptco
      WHERE craptco.cdcopant = pr_cdcopant
        AND craptco.nrctaant = pr_nrctaant;
     rw_craptco cr_craptco%ROWTYPE;                     

     --Variaveis Locais
     vr_cdcritic INTEGER;
     vr_cdprogra VARCHAR2(10);
     vr_dscritic VARCHAR2(4000);
     vr_nmarqlog VARCHAR2(400) := 'prcctl_' || to_char(SYSDATE, 'RRRR') || to_char(SYSDATE,'MM') || to_char(SYSDATE,'DD') || '.log';
      
     --Variaveis de Excecao
     vr_exc_saida  EXCEPTION;
     vr_exc_email  EXCEPTION;
     vr_exc_fimprg EXCEPTION;

     -- Diretorio e arquivos para processamento
     vr_datatual         DATE;
     vr_dir_sicredi_teds VARCHAR2(200);
     vr_listaarq         VARCHAR2(4000); -- Lista de arquivos

     -- Variaveis para email
     vr_dsremete VARCHAR2(1000);
     vr_dsassunt VARCHAR2(100);
     vr_dscorpoe VARCHAR2(1000);
     vr_flgencer BOOLEAN := FALSE;
     vr_typ_saida VARCHAR2(100);
     vr_des_saida VARCHAR2(1000);

     -- PL/Tables para armazenar os nomes de arquivos a serem processados
     vr_tbarqlst  gene0002.typ_split;
     vr_idxnumbe integer;
    
     -- Outra estrutura para armazena-los em ordem alfabetica
     TYPE vr_tab_arquivos IS
       TABLE OF VARCHAR2(100)
         INDEX BY VARCHAR2(100);
     vr_tbarquiv vr_tab_arquivos;
     vr_idxtexto VARCHAR2(100);

     -- Variaveis para leitura do arquivo
     vr_arqhandle   utl_file.file_type;
     vr_dslinharq   VARCHAR2(600);

     -- Header
     vr_nmevehead   VARCHAR2(3);
     vr_nrseqhead   NUMBER(5);
     vr_nrctrlif    NUMBER;
     vr_dtarquiv    DATE;

     -- Linha a LInha
     vr_nrcpfcgc    NUMBER;
     vr_nrdconta    NUMBER;
     vr_nrdconta_new NUMBER;
     vr_nmprimtl    VARCHAR2(60);
     vr_flgexis_cpf BOOLEAN;
     vr_flgexis_cta BOOLEAN;
     vr_segundo_ttl BOOLEAN;
     vr_cdcooper    NUMBER;
     vr_cdmotivo    varchar2(100);
     vr_nrispbif    NUMBER;
     vr_vloperac    NUMBER(12,2);
     vr_cdbandif    NUMBER;
     vr_cdagedif    NUMBER;
     vr_nrctadif    NUMBER;
     vr_nrcpfdif    NUMBER;

     -- Variaveis para controle das operacoes do arquivo
     vr_qtproces NUMBER;
     vr_qtrejeit NUMBER;
     vr_vlrtotal NUMBER;
     vr_fltxterr BOOLEAN;
     vr_dstxterr VARCHAR2(32767);
     vr_cltxterr CLOB;
     vr_hasfound BOOLEAN;

     -- Tabela de retorno LANC0001 (PJR450 08/06/2018).
     vr_tab_retorno  lanc0001.typ_reg_retorno;
     vr_incrineg     NUMBER;
    
	 
   FUNCTION fn_mes(pr_data IN DATE) RETURN VARCHAR2 IS
   BEGIN
     IF to_number(to_char(pr_data,'mm')) < 10 THEN
       RETURN to_number(to_char(pr_data,'mm'));
     ELSE
       IF to_char(pr_data,'mm') = 10 THEN
         RETURN 'o';
       ELSIF to_char(pr_data,'mm') = 11 THEN
         RETURN 'n';
       ELSE
         RETURN 'd';
       END IF;
     END IF;
   END;
   
   /* Funcao para mover o arquivo processado */
   FUNCTION fn_move_arquivo(pr_nmarquiv IN VARCHAR
                           ,pr_dtarquiv IN DATE
                           ,pr_dir_sicredi_teds IN VARCHAR
                           ,pr_arqcomerro IN BOOLEAN
                           ,pr_dscritic OUT VARCHAR) RETURN BOOLEAN IS
   BEGIN  
     DECLARE 
         vr_dir_backup_teds  VARCHAR2(200);
     BEGIN
       -- Devemos mover o arquivo conforme estrutura:
       -- Estrutura base: /usr/connect/sicredi/ted
       -- Sub-diretório: /RRRR
       -- Sub-diretório: /MM.RRRR
       -- Sub-diretório: /DD.MM.RRRR

       IF NOT pr_dtarquiv IS NULL THEN
         -- Montar caminho completo do diretório:
         vr_dir_backup_teds := pr_dir_sicredi_teds||'/'||to_char(pr_dtarquiv,'RRRR')
                            ||'/'||to_char(pr_dtarquiv,'MM')||'.'||to_char(pr_dtarquiv,'RRRR')
                            ||'/'||to_char(pr_dtarquiv,'DD')||'.'||to_char(pr_dtarquiv,'MM')||'.'||to_char(pr_dtarquiv,'RRRR');

       ELSE
         -- Montar caminho completo do diretório:
         vr_dir_backup_teds := pr_dir_sicredi_teds||'/'||to_char(SYSDATE,'RRRR')
                            ||'/'||to_char(SYSDATE,'MM')||'.'||to_char(SYSDATE,'RRRR')
                            ||'/'||to_char(SYSDATE,'DD')||'.'||to_char(SYSDATE,'MM')||'.'||to_char(SYSDATE,'RRRR');
       END IF;
       
       -- Primeiro garantimos que o diretorio exista
       IF NOT gene0001.fn_exis_diretorio(vr_dir_backup_teds) THEN
         -- Efetuar a criação do mesmo
         gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir -p '||vr_dir_backup_teds
                                    ,pr_typ_saida   => vr_typ_saida
                                    ,pr_des_saida   => vr_des_saida);

         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           vr_dscritic := 'Nao foi possivel criar diretorios para mover os arquivos processados.';
           RETURN FALSE;
         END IF;           
              
       END IF;

       IF pr_arqcomerro THEN
         
         --Move o arquivo XML fisico de envio
         GENE0001.pc_OScommand (pr_typ_comando => 'S'
                               ,pr_des_comando => 'mv '||pr_dir_sicredi_teds||'/'||pr_nmarquiv||' '||vr_dir_backup_teds ||'/ERRO_'||pr_nmarquiv|| ' 2> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_dscritic);
         
         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           RETURN FALSE;
         END IF;                              
       
       ELSE
            
         --Move o arquivo XML fisico de envio
         GENE0001.pc_OScommand (pr_typ_comando => 'S'
                               ,pr_des_comando => 'mv '||pr_dir_sicredi_teds||'/'||rtrim(pr_nmarquiv,gene0001.fn_extensao_arquivo(pr_nmarquiv))||'* '||vr_dir_backup_teds || ' 2> /dev/null'
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_dscritic);                      
                               
         --Se ocorreu erro dar RAISE
         IF vr_typ_saida = 'ERR' THEN
           RETURN FALSE;
         END IF;
                               
       END IF;     
             
       RETURN TRUE;
       
     END;
     
   END fn_move_arquivo;
  
   ---------------------------------------
   -- Inicio Bloco Principal pc_crps707
   ---------------------------------------
   BEGIN
     --Atribuir o nome do programa que está executando
     vr_cdprogra:= 'CRPS707';

     -- Incluir nome do módulo logado
     GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                               ,pr_action => NULL);

     -- Validações iniciais do programa
     BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);

     --Se retornou critica aborta programa
     IF vr_cdcritic <> 0 THEN
       
       --Descricao do erro recebe mensagam da critica
       vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       
       -- Envio centralizado de log de erro
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
                                                     
       --Sair do programa
       RAISE vr_exc_saida;
       
     END IF;
     
     --> Gerar log
     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                pr_ind_tipo_log => 1, --> Mensagem
                                pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                   ' - '|| vr_cdprogra ||' --> Iniciando processo de TEDs Sicredi',
                                pr_nmarqlog     => vr_nmarqlog);                                
     
     --Limpa a tabela de controle de arquivos. Remove todos os registros do ano anterior.
     BEGIN 
       
       DELETE tbted_control_arq
        WHERE to_char(tbted_control_arq.dtrefere,'RRRR') = to_char(TRUNC(SYSDATE,'YEAR')-1,'RRRR');
       
     EXCEPTION
       WHEN OTHERS THEN
         --Descricao do erro recebe mensagam da critica
         vr_dscritic := 'Nao foi possivel limpar a tabela de controle de arquivos processados.';
         
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
                                                       
         --Sair do programa
         RAISE vr_exc_saida;
     
     END;                             
     
     -- Busca diretorio das TEDs para processamento
     vr_dir_sicredi_teds := gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIR_SICREDI_TEDS');
     
     -- Busca remetente de email
     vr_dsremete := gene0001.fn_param_sistema('CRED',pr_cdcooper,'EMAIL_SICREDI_TEDS');
     
     -- Data para processamento
     vr_datatual := trunc(SYSDATE);

     -- Efetuar leitura dos arquivos do diretorio
     gene0001.pc_lista_arquivos(pr_path     => vr_dir_sicredi_teds
                               ,pr_pesq     => 're1714%.'||to_char(vr_datatual,'dd')||fn_mes(vr_datatual)
                               ,pr_listarq  => vr_listaarq
                               ,pr_des_erro => vr_dscritic);
     -- Se houver erro
     IF vr_dscritic IS NOT NULL THEN
       -- Envio centralizado de log de erro
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
                                                     
       RAISE vr_exc_saida;
     END IF;

     -- Se possuir arquivos para serem processados
     IF vr_listaarq IS NOT NULL THEN
       
       -- Carregar a lista de arquivos txt na pl/table
       vr_tbarqlst := gene0002.fn_quebra_string(pr_string => vr_listaarq);
       
       -- Recriar a pltable ordenado por varchar2 para garantir o sequenciamento dos arquivos
       vr_idxnumbe := vr_tbarqlst.first;
       
       WHILE vr_idxnumbe IS NOT NULL LOOP
         vr_tbarquiv(vr_tbarqlst(vr_idxnumbe)) := vr_tbarqlst(vr_idxnumbe);
         vr_idxnumbe := vr_tbarqlst.next(vr_idxnumbe);
       END LOOP;
       
       -- Iniciar CLOB de erros
       dbms_lob.createtemporary(vr_cltxterr, TRUE, dbms_lob.CALL);
       dbms_lob.open(vr_cltxterr,dbms_lob.lob_readwrite);                  
       
       -- Para cada arquivo encontrado
       vr_idxtexto := vr_tbarquiv.first;
       
       WHILE vr_idxtexto IS NOT NULL LOOP
         -- Criar bloco para tratamento arquivo por arquivo
         BEGIN
           --> Gerar log
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                      pr_ind_tipo_log => 1, --> Mensagem
                                      pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                         ' - '|| vr_cdprogra ||' --> Iniciando integracao do arquivo '||vr_idxtexto,
                                      pr_nmarqlog     => vr_nmarqlog); 

           -- Verificar se o arquivo já não foi processado (existe na tabela mesmo nome)
           vr_flgexis := 0;
           
           OPEN cr_nmarquiv(pr_nmarquiv => vr_idxtexto);
           
           FETCH cr_nmarquiv INTO vr_flgexis;
           
           CLOSE cr_nmarquiv;
           
           -- Se o arquivo já foi processado
           IF vr_flgexis = 1 THEN
             
             -- Gerar email ao Financeiro
             vr_dsassunt := 'TEDs SICREDI - ARQUIVO JA PROCESSADO';
             vr_dscorpoe := 'Arquivo '||vr_idxtexto||' já foi integrado anteriormente, favor verificar.';
             
             -- Direcionar para a saida com envio de email
             RAISE vr_exc_email;
             
           END IF;

           -- Zerar variaveis para controle das operacoes do arquivo
           vr_qtproces := 0;
           vr_qtrejeit := 0;
           vr_vlrtotal := 0;
           
           vr_fltxterr := FALSE;
           vr_dstxterr := null;
           vr_cltxterr := ' ';

           -- Efetuar leitura do conteudo do arquivo --
           gene0001.pc_abre_arquivo(pr_nmdireto => vr_dir_sicredi_teds
                                   ,pr_nmarquiv => vr_idxtexto
                                   ,pr_tipabert => 'R'
                                   ,pr_utlfileh => vr_arqhandle
                                   ,pr_des_erro => vr_dscritic);

           -- Leitura do header
           gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandle
                                       ,pr_des_text => vr_dslinharq);

           -- Garantir tipo do registro
           IF substr(vr_dslinharq,1,2) <> 'HH' THEN
             
             vr_dsassunt := 'TEDs SICREDI - ARQUIVO SEM REGISTRO HEADER';
             vr_dscorpoe := 'Arquivo '||vr_idxtexto||' com problema. Nao ha Header (HH).';
             
             -- Direcionar para a saida com envio de email e encerramento
             vr_flgencer := TRUE;
             RAISE vr_exc_email;
             
           END IF;

           -- Verificar tipo da mensagem
           vr_nmevehead := substr(vr_dslinharq,3,3);
           
           IF vr_nmevehead NOT IN('STR','PAG') THEN
            
             vr_dsassunt := 'TEDs SICREDI - ARQUIVO COM TIPO DE MENSAGEM INVALIDO';
             vr_dscorpoe := 'Arquivo '||vr_idxtexto||' com problema. Tipo de Mensagem Inválida (STR ou PAG).';
             
             -- Direcionar para a saida com envio de email e encerramento
             vr_flgencer := TRUE;
             RAISE vr_exc_email;
             
           END IF;

           -- Verificar data do arquivo
           BEGIN
             vr_dtarquiv := TO_DATE(substr(vr_dslinharq,6,6),'DDMMRR');
           EXCEPTION
             WHEN OTHERS THEN
               vr_dsassunt := 'TEDs SICREDI - ARQUIVO COM DATA INVALIDA';
               vr_dscorpoe := 'Arquivo '||vr_idxtexto||' com problema Header - Data --> '||substr(vr_dslinharq,6,6);
               
               -- Direcionar para a saida com envio de email e encerramento
               vr_flgencer := TRUE;
               RAISE vr_exc_email;
               
           END;

           -- Verificar se a data presente no header corresponde a data informada no nome do arquivo
           IF vr_datatual <> vr_dtarquiv THEN           
             
             vr_dsassunt := 'TEDs SICREDI - ARQUIVO COM DATA INVALIDA';
             vr_dscorpoe := 'Arquivo '||vr_idxtexto||' com problema Header - Data --> '||substr(vr_dslinharq,6,6);
             
             -- Direcionar para a saida com envio de email e encerramento
             vr_flgencer := TRUE;
             RAISE vr_exc_email;
             
           END IF;

           -- Verificar sequencia do header
           BEGIN
             vr_nrseqhead := substr(vr_dslinharq,12,2);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dsassunt := 'TEDs SICREDI - ARQUIVO COM SEQUENCIA INVALIDA';
               vr_dscorpoe := 'Arquivo '||vr_idxtexto||' com problema Header - Sequencia --> '||substr(vr_dslinharq,12,2);
               
               -- Direcionar para a saida com envio de email e encerramento
               vr_flgencer := TRUE;
               RAISE vr_exc_email;
               
           END;

           --Verifica se o sequencial no header corresponde ao informado no nome do arquivo
           IF substr(vr_idxtexto,7,2) <> vr_nrseqhead THEN
             
             vr_dsassunt := 'TEDs SICREDI - ARQUIVO COM SEQUENCIA INVALIDA';
             vr_dscorpoe := 'Arquivo '||vr_idxtexto||' com problema Header - Sequencia --> '||substr(vr_dslinharq,12,2);
             -- Direcionar para a saida com envio de email e encerramento
             vr_flgencer := TRUE;
             RAISE vr_exc_email; 
                         
           END IF;

           -- Somente validar se o arquivo atual não é o primeiro
           IF vr_nrseqhead <> 1 THEN           
             -- Sequencia do arquivo deve ser imediamente posterior a ultima processada para a data
             vr_flgexis := 0;
             
             OPEN cr_sqarquiv(vr_dtarquiv,vr_nrseqhead-1);
             
             FETCH cr_sqarquiv INTO vr_flgexis;
             
             CLOSE cr_sqarquiv;

             IF vr_flgexis = 0 THEN
               
               vr_dsassunt := 'TEDs SICREDI - ARQUIVO COM SEQUENCIA INVALIDA';
               vr_dscorpoe := 'Arquivo '||vr_idxtexto||' com problema Header - Sequencia recebida --> '||vr_nrseqhead||', Sequencia esperada --> '||(vr_nrseqhead-1);
               
               -- Gerar email ao Financeiro
               gene0003.pc_solicita_email(pr_cdcooper       => pr_cdcooper
                                        ,pr_cdprogra        => 'PC_'||vr_cdprogra
                                        ,pr_des_destino     => vr_dsremete
                                        ,pr_des_assunto     => vr_dsassunt
                                        ,pr_des_corpo       => vr_dscorpoe
                                        ,pr_des_anexo       => NULL
                                        ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                        ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                        ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                        ,pr_des_erro        => vr_dscritic);
             END IF;
           END IF;  

           -- Processamento para cada registro
           LOOP
             BEGIN
               -- Limpeza de variaveis registro a registro
               vr_flgexis_cpf := false;
               vr_flgexis_cta := false;
               vr_segundo_ttl := FALSE;
               vr_cdcooper    := 0;
               vr_nrdconta    := 0;
               vr_nmprimtl    := ' ';
               vr_nrcpfcgc    := 0;
               vr_vloperac    := 0;
               vr_nrispbif    := 0;
               rw_crapcop     := null;
               rw_crapdat     := null;
               rw_crapass     := null;
               vr_cdbandif    := 0;
               vr_cdagedif    := 0;
               vr_nrctadif    := 0;
               vr_nrcpfdif    := 0;

               -- Efetuar leitura das linhas do arquivo
               gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandle
                                           ,pr_des_text => vr_dslinharq);
                                           
               -- Garantir tipo do registro
               IF substr(vr_dslinharq,1,2) NOT IN('05','06','TT') THEN
                 -- Tipo invalido
                 vr_cdmotivo := 'Tipo Registro Invalido = ' || substr(vr_dslinharq,1,2);
                 RAISE vr_exc_saida;
               END IF;
               
               -- No Trailler, sair do LOOP
               IF substr(vr_dslinharq,1,2) = 'TT' THEN
                 EXIT;
               END IF;

               -- Ler ISPB
               BEGIN
                 IF substr(vr_dslinharq,1,2) = '05' THEN
                   vr_nrispbif := substr(vr_dslinharq,407,8);
                 ELSE
                   vr_nrispbif := substr(vr_dslinharq,404,8);
                 END IF;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdmotivo := 'ISPB Invalido = ';
                   IF substr(vr_dslinharq,1,2) = '05' THEN
                     vr_cdmotivo := vr_cdmotivo || substr(vr_dslinharq,407,8);
                   ELSE
                     vr_cdmotivo := vr_cdmotivo || substr(vr_dslinharq,404,8);
                   END IF;
                   RAISE vr_exc_saida;
               END;

               -- Numero da Operação (remover STR a frente, caso venha)
               BEGIN
                 vr_nrctrlif := to_number(ltrim(substr(vr_dslinharq,3,20),'STR'));
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdmotivo := 'Numero Operacao invalido = ' || substr(vr_dslinharq,3,20);
                   RAISE vr_exc_saida;
               END;

               -- Busca do valor
               BEGIN
                 vr_vloperac := to_number(substr(vr_dslinharq,23,14))/100;
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdmotivo := 'Valor invalido = ' || substr(vr_dslinharq,23,14);
                   RAISE vr_exc_saida;
               END;

               -- Busca do nome do destino
               IF substr(vr_dslinharq,1,2) = '05' THEN
                 vr_nmprimtl := substr(vr_dslinharq,223,50);
               ELSE
                 vr_nmprimtl := substr(vr_dslinharq,288,50);
               END IF;  

               -- Busca da conta a creditar
               BEGIN
                 IF substr(vr_dslinharq,1,2) = '05' THEN
                   vr_nrdconta := substr(vr_dslinharq,43,13);
                 ELSE
                   vr_nrdconta := substr(vr_dslinharq,70,13);
                 END IF;  
               EXCEPTION
                 WHEN OTHERS THEN
                   IF substr(vr_dslinharq,1,2) = '05' THEN
                     vr_cdmotivo := 'Conta invalida = ' || substr(vr_dslinharq,43,13);
                   ELSE
                     vr_cdmotivo := 'Conta invalida = ' || substr(vr_dslinharq,70,13);
                   END IF; 
                   
                   RAISE vr_exc_saida;
               END;

               -- Busca do CPF da TED
               BEGIN
                 IF substr(vr_dslinharq,1,2) = '05' THEN
                   vr_nrcpfcgc := substr(vr_dslinharq,209,14);
                 ELSE
                   vr_nrcpfcgc := substr(vr_dslinharq,274,14);
                 END IF;
               EXCEPTION
                 WHEN OTHERS THEN
                   IF substr(vr_dslinharq,1,2) = '05' THEN
                     vr_cdmotivo := 'CPF invalido = ' || substr(vr_dslinharq,209,14);
                   ELSE
                     vr_cdmotivo := 'CPF invalido = ' || substr(vr_dslinharq,274,14);
                   END IF;                   
                   
                   RAISE vr_exc_saida;
               END;

               -- Verificar a existencia do CPF na Cooperativa
               FOR rw_crapttl IN cr_crapttl(pr_nrcpfcgc => vr_nrcpfcgc) LOOP
                 
                 -- Encontrou pelo menos 1 com CPF
                 vr_flgexis_cpf := true;
                 
                 -- Indica que é segundo titular
                 vr_segundo_ttl := TRUE;
                 
                 -- Se a conta for igual a conta do arquivo
                 IF rw_crapttl.nrdconta = vr_nrdconta THEN
                   
                   -- Apenas alimenta a flag de encontro
                   vr_flgexis_cta := true;
                   
                   -- Busca a conta do primeiro titular
                   OPEN cr_crapass3(pr_cdcooper => rw_crapttl.cdcooper 
                                   ,pr_nrdconta => vr_nrdconta);
                   
                   FETCH cr_crapass3 INTO rw_crapass3;
                   
                   IF cr_crapass3%FOUND THEN
               
                     -- Se a conta estiver ativa
                     IF rw_crapass3.dtdemiss IS NULL THEN
                       -- Se já tinhamos encontrado
                       IF vr_cdcooper > 0 THEN
                         -- Geraremos critica pois não pode haver mais de uma conta ativa em outras singulares
                         vr_cdmotivo := 'Conta Duplicada';
                         RAISE vr_exc_saida;
                       ELSE
                         -- Armazena a Cooperativa da conta e nome do associado
                         vr_cdcooper := rw_crapass3.cdcooper;
                         vr_nmprimtl := rw_crapass3.nmprimtl;
                       END IF;
                     END IF;
               
                   END IF;
                 
                   CLOSE cr_crapass3;                   
                 
               END IF;
               
               END LOOP;
               
               FOR rw_crapass IN cr_crapass(pr_nrcpfcgc => vr_nrcpfcgc) LOOP
                 
                 -- Encontrou pelo menos 1 com CPF
                 vr_flgexis_cpf := true;
                 
                 -- Se a conta for igual a conta do arquivo
                 IF rw_crapass.nrdconta = vr_nrdconta THEN
                   
                   -- Apenas alimenta a flag de encontro
                   vr_flgexis_cta := true;
                   
                   -- Se a conta estiver ativa
                   IF rw_crapass.dtdemiss IS NULL THEN
                     -- Se já tinhamos encontrado
                     IF vr_cdcooper > 0 THEN
                       -- Geraremos critica pois não pode haver mais de uma conta ativa em outras singulares
                       vr_cdmotivo := 'Conta Duplicada';
                       RAISE vr_exc_saida;
                     ELSE
                       -- Armazena a Cooperativa da conta e nome do associado
                       vr_cdcooper := rw_crapass.cdcooper;
                       vr_nmprimtl := rw_crapass.nmprimtl;
                     END IF;
                     
                   END IF;
                   
                 END IF;
                 
               END LOOP;

               -- Se chegou neste ponto e não encontrou pelo CPF
               IF not vr_flgexis_cpf THEN
                 -- Gerar critica
                 vr_cdmotivo := '3 - Ausencia ou Divergencia na Indicacao do CPF/CNPJ.';
                 RAISE vr_exc_saida;
               END IF;

               -- Se chegou neste ponto e não encontrou pelo CPF + Conta
               IF not vr_flgexis_cta THEN
                 -- Gerar critica
                 vr_cdmotivo := '2 - Agencia ou Conta Destinataria do Credito Invalida.';
                 RAISE vr_exc_saida;
               END IF;

               -- Se for segundo titular
               IF vr_segundo_ttl THEN
                 
                 -- Verificar a existencia do CPF/Conta na Cooperativa
                 OPEN cr_crapttl2(pr_nrdconta => vr_nrdconta
                                 ,pr_nrcpfcgc => vr_nrcpfcgc);
                 
                 FETCH cr_crapttl2 INTO rw_crapttl2;
                 
                 IF cr_crapttl2%NOTFOUND THEN
                   
                   CLOSE cr_crapttl2;
                   
                   vr_cdmotivo := '1 - Ausencia ou Divergencia na Indicacao do CPF/CNPJ.';
                   RAISE vr_exc_saida;
                   
               END IF;

                 CLOSE cr_crapttl2;
                 
               ELSE  
                 
               -- Verificar a existencia do CPF/Conta na Cooperativa
               OPEN cr_crapass2(pr_nrdconta => vr_nrdconta
                               ,pr_nrcpfcgc => vr_nrcpfcgc);
               
               FETCH cr_crapass2 INTO rw_crapass2;
               
               IF cr_crapass2%NOTFOUND THEN
                 
                 CLOSE cr_crapass2;
                 
                 vr_cdmotivo := '1 - Ausencia ou Divergencia na Indicacao do CPF/CNPJ.';
                 RAISE vr_exc_saida;
                 
               END IF;
               
               CLOSE cr_crapass2;
               
               END IF;
                              
               -- Se não achou nenhuma conta ativa
               IF vr_cdcooper = 0 THEN
                 -- Gerar critica
                 vr_cdmotivo := '1 - Conta Destinataria do Credito Encerrada.';
                 RAISE vr_exc_saida;
               END IF;

               --Verificar se é um cooperado migrado
               OPEN cr_craptco(pr_cdcopant => vr_cdcooper 
                              ,pr_nrctaant => vr_nrdconta);
                              
               FETCH cr_craptco INTO rw_craptco;
               
               IF cr_craptco%FOUND THEN
                 
                 vr_cdcooper     := rw_craptco.cdcooper;
                 vr_nrdconta_new := rw_craptco.nrdconta;
                 
               ELSE
                 
                 vr_nrdconta_new := vr_nrdconta;
                 
               END IF;
               
               CLOSE cr_craptco;

               -- Busca dados da origem da TED
               BEGIN
                 -- Separar conforme tipo da mensagem
                 IF substr(vr_dslinharq,1,2) = '05' THEN
                   vr_cdbandif := substr(vr_dslinharq,56,3);
                   vr_cdagedif := 0;
                   vr_nrctadif := 0;
                   vr_nrcpfdif := substr(vr_dslinharq,339,14);
                 ELSE
                   vr_cdbandif := substr(vr_dslinharq,42,3);
                   vr_cdagedif := substr(vr_dslinharq,45,4);
                   vr_nrctadif := substr(vr_dslinharq,51,13);
                   vr_nrcpfdif := substr(vr_dslinharq,209,14);
                 END IF;
                 
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdmotivo := 'Erro na leitura do Bco, Age, Cta e CPF origem.';
                   RAISE vr_exc_saida;
               END;

               -- Busca informacoes da Cooperativa encontrada
               OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
               
               FETCH cr_crapcop INTO rw_crapcop;
               
               CLOSE cr_crapcop;

               -- Verifica se a data esta cadastrada
               OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
               
               
               FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
               
               CLOSE BTCH0001.cr_crapdat;

               -- Busca Lote
               OPEN cr_craplot(pr_cdcooper => vr_cdcooper
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_nrdolote => 8482);
               
               FETCH cr_craplot INTO rw_craplot;
               
               vr_hasfound := cr_craplot%FOUND;
               
               CLOSE cr_craplot;

               -- Se não existir
               IF NOT vr_hasfound THEN
                 BEGIN
                   -- Cria Lote
                   INSERT INTO craplot (cdcooper
                                       ,dtmvtolt
                                       ,cdagenci
                                       ,cdbccxlt
                                       ,nrdolote
                                       ,tplotmov
                                       ,qtcompln
                                       ,qtinfoln
                                       ,vlinfocr
                                       ,vlcompcr
                                       ,nrseqdig)
                                 VALUES(vr_cdcooper
                                       ,rw_crapdat.dtmvtolt
                                       ,1           -- cdagenci
                                       ,100         -- cdbccxlt
                                       ,8482
                                       ,1
                                       ,1
                                       ,1
	                                     ,vr_vloperac
                                       ,vr_vloperac
                                       ,1)
                              RETURNING nrseqdig
                                   INTO rw_craplot.nrseqdig;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_cdmotivo := 'Erro ao gravar LOTE:'||sqlerrm;
                     RAISE vr_exc_saida;
                 END;
                 
               ELSE -- Se Existir
                 BEGIN
				           -- Atualiza Lote
                   UPDATE craplot
                      SET qtcompln = nvl(craplot.qtcompln,0) + 1
                        , qtinfoln = nvl(craplot.qtinfoln,0) + 1
                        , vlinfocr = nvl(craplot.vlinfocr,0) + vr_vloperac
                        , vlcompcr = nvl(craplot.vlcompcr,0) + vr_vloperac
                        , nrseqdig = nvl(craplot.nrseqdig,0) + 1
                    WHERE craplot.cdcooper = vr_cdcooper
                      AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
                      AND craplot.cdagenci = 1
                      AND craplot.cdbccxlt = 100
                      AND craplot.nrdolote = 8482
                RETURNING nrseqdig
                     INTO rw_craplot.nrseqdig;
                 EXCEPTION
                   WHEN OTHERS THEN
                     vr_cdmotivo := 'Erro ao atualizar LOTE:' || sqlerrm;
                     RAISE vr_exc_saida;
                 END;
                 
               END IF;

               -- Cria o lancamento em C/C
               lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                , pr_cdagenci => 1
                                                , pr_cdbccxlt => 100
                                                , pr_nrdolote => 8482
                                                , pr_nrdconta => vr_nrdconta_new
                                                , pr_nrdocmto => rw_craplot.nrseqdig
                                                , pr_cdhistor => 1787
                                                , pr_nrseqdig => rw_craplot.nrseqdig
                                                , pr_vllanmto => vr_vloperac
                                                , pr_nrdctabb => vr_nrdconta_new
                                                --, pr_cdpesqbb => vr_cdpeslcm
                                                --, pr_vldoipmf IN  craplcm.vldoipmf%TYPE default 0
                                                --, pr_nrautdoc IN  craplcm.nrautdoc%TYPE default 0
                                                --, pr_nrsequni IN  craplcm.nrsequni%TYPE default 0
                                                --, pr_cdbanchq => rw_tbdoctco(vr_indoctco).cdbandoc
                                                --, pr_cdcmpchq => rw_tbdoctco(vr_indoctco).cdcmpdoc
                                                --, pr_cdagechq => rw_tbdoctco(vr_indoctco).cdagedoc
                                                --, pr_nrctachq => rw_tbdoctco(vr_indoctco).nrctadoc
                                                --, pr_nrlotchq IN  craplcm.nrlotchq%TYPE default 0
                                                --, pr_sqlotchq => rw_tbdoctco(vr_indoctco).sqlotdoc
                                                --, pr_dtrefere => vr_dtleiarq
                                                , pr_hrtransa => to_char(SYSDATE,'sssss')
                                                --, pr_cdoperad IN  craplcm.cdoperad%TYPE default ' '
                                                --, pr_dsidenti IN  craplcm.dsidenti%TYPE default ' '
                                                , pr_cdcooper => vr_cdcooper
                                                , pr_nrdctitg => gene0002.fn_mask(vr_nrdconta_new,'99999999')
                                                --, pr_dscedent IN  craplcm.dscedent%TYPE default ' '
                                                --, pr_cdcoptfn IN  craplcm.cdcoptfn%TYPE default 0
                                                --, pr_cdagetfn IN  craplcm.cdagetfn%TYPE default 0
                                                --, pr_nrterfin IN  craplcm.nrterfin%TYPE default 0
                                                --, pr_nrparepr IN  craplcm.nrparepr%TYPE default 0
                                                --, pr_nrseqava IN  craplcm.nrseqava%TYPE default 0
                                                --, pr_nraplica IN  craplcm.nraplica%TYPE default 0
                                                --, pr_cdorigem IN  craplcm.cdorigem%TYPE default 0
                                                --, pr_idlautom IN  craplcm.idlautom%TYPE default 0
                                                -------------------------------------------------
                                                -- Dados do lote (Opcional)
                                                -------------------------------------------------
                                                --, pr_inprolot  => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                                --, pr_tplotmov  => 1
                                                , pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                                , pr_incrineg  => vr_incrineg      -- OUT Indicador de crítica de negócio
                                                , pr_cdcritic  => vr_cdcritic      -- OUT
                                                , pr_dscritic  => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lançamento (CRAPLCM, conta transitória, etc)

               IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
                   vr_cdmotivo := 'Erro ao criar Transferencia em C/C: '||vr_dscritic;
                   RAISE vr_exc_saida;	
               END IF;
			
               -- Efetuar geração do LOG da TED com sucesso
               sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                        ,pr_idorigem => 1
                                        ,pr_cdprogra => 'CRPS707'
                                        ,pr_idsitmsg => 3 /*recebida com sucesso*/
                                        ,pr_nmarqmsg => vr_idxtexto
                                        ,pr_nmevento => vr_nmevehead
                                        ,pr_nrctrlif => vr_nrctrlif
                                        ,pr_vldocmto => vr_vloperac
                                        ,pr_cdbanctl => rw_crapcop.cdbcoctl
                                        ,pr_cdagectl => rw_crapcop.cdagectl
                                        ,pr_nrdconta => vr_nrdconta_new
                                        ,pr_nmcopcta => vr_nmprimtl
                                        ,pr_nrcpfcop => vr_nrcpfcgc
                                        ,pr_cdbandif => vr_cdbandif
                                        ,pr_cdagedif => vr_cdagedif
                                        ,pr_nrctadif => vr_nrctadif
                                        ,pr_nmtitdif => SUBSTR(vr_dslinharq,353,50)
                                        ,pr_nrcpfdif => vr_nrcpfdif
                                        ,pr_cdidenti => ''
                                        ,pr_dsmotivo => ''
                                        ,pr_cdagenci => 0
                                        ,pr_nrdcaixa => 0
                                        ,pr_cdoperad => '1'
                                        ,pr_nrispbif => vr_nrispbif
                                        ,pr_cdifconv => 1
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                                        
               IF vr_dscritic IS NOT NULL THEN
                 vr_cdmotivo := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
                              
               -- Efetuar geração do LOG da TED com sucesso
               sspb0001.pc_grava_log_ted(pr_cdcooper => 16 --Viacredi Altovale
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                        ,pr_idorigem => 1
                                        ,pr_cdprogra => 'CRPS707'
                                        ,pr_idsitmsg => 1 /*enviada com sucesso*/
                                        ,pr_nmarqmsg => vr_idxtexto
                                        ,pr_nmevento => vr_nmevehead
                                        ,pr_nrctrlif => vr_nrctrlif
                                        ,pr_vldocmto => vr_vloperac
                                        ,pr_cdbanctl => rw_crapcop.cdbcoctl
                                        ,pr_cdagectl => rw_crapcop.cdagectl
                                        ,pr_nrdconta => vr_nrdconta_new
                                        ,pr_nmcopcta => vr_nmprimtl
                                        ,pr_nrcpfcop => vr_nrcpfcgc
                                        ,pr_cdbandif => vr_cdbandif
                                        ,pr_cdagedif => vr_cdagedif
                                        ,pr_nrctadif => vr_nrctadif
                                        ,pr_nmtitdif => SUBSTR(vr_dslinharq,353,50)
                                        ,pr_nrcpfdif => vr_nrcpfdif
                                        ,pr_cdidenti => ''
                                        ,pr_dsmotivo => ''
                                        ,pr_cdagenci => 0
                                        ,pr_nrdcaixa => 0
                                        ,pr_cdoperad => '1'
                                        ,pr_nrispbif => vr_nrispbif
                                        ,pr_cdifconv => 1
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                                        
               IF vr_dscritic IS NOT NULL THEN
                 vr_cdmotivo := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
               
               --> Gerar log
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                          pr_ind_tipo_log => 1, --> Mensagem -- não é erro tratado
                                          pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                             ' - '|| vr_cdprogra ||' --> TED para Conta '||vr_nrdconta_new||' no valor de '
                                                             || to_char(vr_vloperac,'fm999g999g990d00') || ' efetuada com sucesso.',
                                          pr_nmarqlog     => vr_nmarqlog);                

               -- Chegou ao final, então incrementamos a quantidade de registros processados
               vr_qtproces := vr_qtproces + 1;
               vr_vlrtotal := vr_vlrtotal + vr_vloperac;
               
             EXCEPTION
               WHEN vr_exc_saida THEN

                 -- Incrementar quantidade de erros
                 vr_qtrejeit := vr_qtrejeit + 1;
                 
                 -- Se ainda não iniciamos o texto de erro
                 IF NOT vr_fltxterr THEN
                   
                   -- Atualizar o controle
                   vr_fltxterr := TRUE;
                   
                   -- Iniciar o CLOB com a montagem da tabela
                   gene0002.pc_escreve_xml(pr_xml => vr_cltxterr
                                          ,pr_texto_completo => vr_dstxterr
                                          ,pr_texto_novo => '<table>' ||
                                                            '<thead align="center" style="background-color: #DCDCDC;">' ||
                                                              '<td width="100px">' ||
                                                                '<b>Tipo Trans.</b>' ||
                                                              '</td>' ||
                                                              '<td width="100px">' ||
                                                                '<b>Nr. Operação</b>' ||
                                                              '</td>' ||
                                                              '<td width="100px">' ||
                                                                '<b>Valor</b>' ||
                                                              '</td>' ||
                                                              '<td width="100px">' ||
                                                                '<b>Dt.Arquivo</b>' ||
                                                              '</td>' ||
                                                              '<td width="100px">' ||
                                                                '<b>Sq.Geração</b>' ||
                                                              '</td>' ||
                                                              '<td width="120px">' ||
                                                                '<b>Identificador</b>' ||
                                                              '</td>' ||
                                                              '<td width="100px">' ||
                                                                '<b>Conta</b>' ||
                                                              '</td>' ||
                                                              '<td width="100px">' ||
                                                                '<b>CPF/CNPJ</b>' ||
                                                              '</td>' ||
                                                              '<td width="200px">' ||
                                                                '<b>Nome</b>' ||
                                                              '</td>' ||
                                                              '<td width="250px">' ||
                                                                '<b>Cod.Devolução</b>' ||
                                                              '</td>' ||
                                                            '</thead>' ||
                                                            '<tbody align="center" style="background-color: #F0F0F0;">');
                 
                 END IF;
                 
                 -- Adicionar informações do registro com erro para o e-mail posterior
                 gene0002.pc_escreve_xml(pr_xml => vr_cltxterr
                                        ,pr_texto_completo => vr_dstxterr
                                        ,pr_texto_novo => '<tr>' ||
                                                            '<td>' ||
                                                              vr_nmevehead ||
                                                            '</td>' ||
                                                            '<td>' ||
                                                              vr_nrctrlif ||
                                                            '</td>' ||
                                                            '<td>' ||
                                                              to_char(vr_vloperac,'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''') || 
                                                            '</td>' ||
                                                            '<td>' ||
                                                              to_char(vr_dtarquiv,'DD/MM/RRRR') ||
                                                            '</td>' ||
                                                            '<td>' ||
                                                              vr_nrseqhead ||
                                                            '</td>' ||
                                                            '<td>' ||
                                                              substr(vr_dslinharq,1,2) ||
                                                            '</td>' ||
                                                            '<td>' ||
                                                               vr_nrdconta ||
                                                            '</td>' ||
                                                            '<td>' ||
                                                               vr_nrcpfcgc ||
                                                            '</td>' ||
                                                            '<td>' ||
                                                              vr_nmprimtl ||
                                                            '</td>' ||
                                                            '<td>' ||
                                                              vr_cdmotivo ||
                                                            '</td>' ||
                                                          '</tr>');

                 -- Efetuar geração do LOG da TED com erro
                 sspb0001.pc_grava_log_ted(pr_cdcooper => pr_cdcooper
                                          ,pr_dttransa => TRUNC(SYSDATE)
                                          ,pr_hrtransa => TO_CHAR(SYSDATE,'SSSSS')
                                          ,pr_idorigem => 1
                                          ,pr_cdprogra => 'CRPS707'
                                          ,pr_idsitmsg => 4 /* Recebida com erro*/
                                          ,pr_nmarqmsg => vr_idxtexto
                                          ,pr_nmevento => vr_nmevehead
                                          ,pr_nrctrlif => vr_nrctrlif
                                          ,pr_vldocmto => vr_vloperac
                                          ,pr_cdbanctl => rw_crapcop.cdbcoctl
                                          ,pr_cdagectl => rw_crapcop.cdagectl
                                          ,pr_nrdconta => vr_nrdconta
                                          ,pr_nmcopcta => vr_nmprimtl
                                          ,pr_nrcpfcop => vr_nrcpfcgc
                                          ,pr_cdbandif => vr_cdbandif
                                          ,pr_cdagedif => vr_cdagedif
                                          ,pr_nrctadif => vr_nrctadif
                                          ,pr_nmtitdif => SUBSTR(vr_dslinharq,353,50)
                                          ,pr_nrcpfdif => vr_nrcpfdif
                                          ,pr_cdidenti => ''
                                          ,pr_dsmotivo => vr_cdmotivo
                                          ,pr_cdagenci => 0
                                          ,pr_nrdcaixa => 0
                                          ,pr_cdoperad => '1'
                                          ,pr_nrispbif => vr_nrispbif
                                          ,pr_cdifconv => 1
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                                          
                 --> Gerar log
                   --Indica que é mensagem e não erro
                   --Chamado 660364 / 663299
                 btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                              pr_ind_tipo_log => 1, --> Mensagem
                                            pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                                 ' - '|| vr_cdprogra ||' --> '||
                                                                 'ALERTA: TED para conta '||vr_nrdconta||' com crítica --> '||vr_cdmotivo,
                                            pr_nmarqlog     => vr_nmarqlog);                                
                                          
                                          
               WHEN no_data_found THEN
                 -- Finalizou a leitura
                 gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandle);
                 
                 EXIT;
               WHEN OTHERS THEN                 

                 cecred.pc_internal_exception;
                                
                 vr_dscritic := 'Erro nao tratado na leitura do arquivo --> '||sqlerrm;
                 RAISE vr_exc_saida;
             END;
             
           END LOOP;
           
           -- Ao final do processamento, efetuar gravação na tabela do arquivo e das operações efetuadas
           BEGIN
             INSERT INTO tbted_control_arq(dtrefere
                                          ,nrseqarq
                                          ,dhtransa
                                          ,qtregist
                                          ,qtproces
                                          ,qtrejeit
                                          ,nmarquiv
                                          ,vltotal)
                                    VALUES(vr_dtarquiv
                                          ,vr_nrseqhead
                                          ,SYSDATE
                                          ,vr_qtproces + vr_qtrejeit
                                          ,vr_qtproces
                                          ,vr_qtrejeit
                                          ,vr_idxtexto
                                          ,vr_vlrtotal);
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Na gravacao da TBTED_CONTROL_ARQ --> '||SQLERRM;
               RAISE vr_exc_saida;
           END;

           gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandle);
           
           -- Preparar e enviar email ao Financeiro listando erros na integração do arquivo
           IF vr_fltxterr THEN
             
             -- Finalizar o clob e gerar arquivo
             gene0002.pc_escreve_xml(pr_xml => vr_cltxterr
                                    ,pr_texto_completo => vr_dstxterr
                                    ,pr_texto_novo => '</tbody></table>'
                                    ,pr_fecha_xml => TRUE);
             
             -- Transformar o CLOB em arquivo para anexar ao email
             gene0002.pc_clob_para_arquivo(pr_clob     => vr_cltxterr
                                          ,pr_caminho  => vr_dir_sicredi_teds
                                          ,pr_arquivo  => 'err_'||vr_idxtexto||'.html'
                                          ,pr_des_erro => vr_dscritic);
             IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             
             -- Terminar a montagem do email
             vr_dsassunt := 'Devolução de TEDs - Sicredi ';
             vr_dscorpoe := 'Olá, solicitamos a devolução das TEDs indicadas na listagem em anexo.';                         
                                     
             -- Gerar email ao Financeiro
             gene0003.pc_solicita_email(pr_cdcooper       => pr_cdcooper
                                      ,pr_cdprogra        => 'PC_'||vr_cdprogra
                                      ,pr_des_destino     => vr_dsremete
                                      ,pr_des_assunto     => vr_dsassunt
                                      ,pr_des_corpo       => vr_dscorpoe || vr_dstxterr
                                      ,pr_des_anexo       => vr_dir_sicredi_teds||'/'||'err_'||vr_idxtexto||'.html'
                                      ,pr_flg_remove_anex => 'S' --> Remover os anexos passados
                                      ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                      ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_dscritic);
             IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             
             IF NOT fn_move_arquivo(pr_nmarquiv => vr_idxtexto
                                   ,pr_dtarquiv => vr_dtarquiv
                                   ,pr_dir_sicredi_teds => vr_dir_sicredi_teds
                                   ,pr_arqcomerro => TRUE
                                   ,pr_dscritic => vr_dscritic) THEN
                                       
               IF trim(vr_dscritic) IS NULL THEN
                 vr_dscritic := 'Nao foi possivel mover o arquivo processado.';
               END IF;
                   
               RAISE vr_exc_saida;
                   
             END IF;

           ELSE
             IF NOT fn_move_arquivo(pr_nmarquiv => vr_idxtexto
                                   ,pr_dtarquiv => vr_dtarquiv
                                   ,pr_dir_sicredi_teds => vr_dir_sicredi_teds
                                   ,pr_arqcomerro => FALSE
                                   ,pr_dscritic => vr_dscritic) THEN
              
               IF trim(vr_dscritic) IS NULL THEN
                 vr_dscritic := 'Nao foi possivel mover o arquivo processado.';
               END IF;

               RAISE vr_exc_saida;
                       
             END IF;
             
           END IF;
             
           --> Gerar log
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                      pr_ind_tipo_log => 1, --> Mensagem
                                      pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                         ' - '|| vr_cdprogra ||' --> Encerramento do processo do arquivo '||vr_idxtexto,
                                      pr_nmarqlog     => vr_nmarqlog);                                 

           -- Efetuar gravação das alterações no banco a cada arquivo
           COMMIT;
           
         EXCEPTION
           WHEN no_data_found THEN

             gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandle);
             
             -- Arquivo vazio
             ROLLBACK;
             
             -- Gerar alerta no LOG
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                        pr_ind_tipo_log => 2, --> erro tratado
                                        pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                           ' - '|| vr_cdprogra ||' --> Erro ao processar arquivo ['
                                                           ||vr_idxtexto||'] --> Arquivo vazio!',
                                        pr_nmarqlog     => vr_nmarqlog);
                                        
             -- Erro critico, saida do processo
             EXIT;
             
           WHEN vr_exc_email THEN

             gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandle);
             
             -- Desfazer alterações
             ROLLBACK;
             
             -- Gerar email ao Financeiro
             gene0003.pc_solicita_email(pr_cdcooper       => pr_cdcooper
                                      ,pr_cdprogra        => 'PC_'||vr_cdprogra
                                      ,pr_des_destino     => vr_dsremete
                                      ,pr_des_assunto     => vr_dsassunt
                                      ,pr_des_corpo       => vr_dscorpoe
                                      ,pr_des_anexo       => NULL
                                      ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                      ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                      ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                      ,pr_des_erro        => vr_dscritic);
                                      
             IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;
             END IF;
             
             -- Gerar alerta no LOG
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                        pr_ind_tipo_log => 2, --> erro tratado
                                        pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                           ' - '|| vr_cdprogra ||' --> Erro ao processar arquivo ['
                                                           ||vr_idxtexto||'] --> '||vr_dscorpoe,
                                        pr_nmarqlog     => vr_nmarqlog);
                                        
             IF NOT fn_move_arquivo(pr_nmarquiv => vr_idxtexto
                                   ,pr_dtarquiv => vr_dtarquiv
                                   ,pr_dir_sicredi_teds => vr_dir_sicredi_teds
                                   ,pr_arqcomerro => TRUE
                                   ,pr_dscritic => vr_dscritic) THEN
                                           
               IF trim(vr_dscritic) IS NULL THEN
                 vr_dscritic := 'Nao foi possivel mover o arquivo processado.';
               END IF;
                       
               RAISE vr_exc_saida;
                       
             END IF;                                                                                   
                                        
             -- Gravar para envio do e-mail
             COMMIT;
             
             -- Se foi solicitado encerramento
             IF vr_flgencer THEN
               EXIT;
             END IF;
             
           WHEN vr_exc_saida THEN

             gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandle);
             
             -- Desgravar alterações pendentes
             ROLLBACK;
             
             -- Gerar alerta no LOG
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                        pr_ind_tipo_log => 2, --> erro tratado
                                        pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                           ' - '|| vr_cdprogra ||' --> Erro ao processar arquivo ['
                                                           ||vr_idxtexto||'] --> ' || vr_dscritic                                                               ,
                                        pr_nmarqlog     => vr_nmarqlog);
                                        
             -- Erro critico, saida do processo
             EXIT;
             
           WHEN OTHERS THEN
             
             cecred.pc_internal_exception;
           
             gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arqhandle);

             -- Desgravar alterações pendentes
             ROLLBACK;
             
             -- Gerar alerta no LOG
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                        pr_ind_tipo_log => 2, --> erro tratado
                                        pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                           ' - '|| vr_cdprogra ||' --> Erro ao processar arquivo ['
                                                           ||vr_idxtexto||'] --> ' || SQLERRM                                                        ,
                                        pr_nmarqlog     => vr_nmarqlog);
                                        
             -- Erro critico, saida do processo
             EXIT;
             
         END;
         
         vr_idxtexto := vr_tbarquiv.next(vr_idxtexto);
         
       END LOOP;
     
     ELSE
       -- Gerar email ao Financeiro
       gene0003.pc_solicita_email(pr_cdcooper       => pr_cdcooper
                                ,pr_cdprogra        => 'PC_CRPS707'
                                ,pr_des_destino     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'EMAIL_SICREDI_TEDS')
                                ,pr_des_assunto     => 'TEDs SICREDI - SEM ARQUIVOS'
                                ,pr_des_corpo       => 'Não foram encontrados arquivos de integração de TEDs SICREDI.'
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
                                
       --> Gerar log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                  pr_ind_tipo_log => 2, --> erro tratado
                                  pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' - '|| vr_cdprogra ||' --> Não foram encontrados arquivos de integração de TEDs SICREDI.'                                                      ,
                                  pr_nmarqlog     => vr_nmarqlog);                                

     END IF;

     -- Processo OK, devemos chamar a fimprg
     btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_stprogra => pr_stprogra);

     --> Gerar log
     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                pr_ind_tipo_log => 1, --> Mensagem
                                pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                   ' - '|| vr_cdprogra ||' --> Encerramento do processo de TEDs Sicredi',
                                pr_nmarqlog     => vr_nmarqlog);                                

     --Salvar informacoes no banco de dados
     COMMIT;
     
   EXCEPTION
     WHEN vr_exc_fimprg THEN
       
       -- Se foi retornado apenas codigo
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

       --Limpar variaveis retorno
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

       -- Efetuar commit pois gravaremos o que foi processo até então
       COMMIT;

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
       
       cecred.pc_internal_exception;
     
       -- Efetuar retorno do erro não tratado
       pr_cdcritic := 0;
       pr_dscritic := 'Erro na procedure pc_crps707. '||sqlerrm;

       -- Efetuar rollback
       ROLLBACK;

   END;

 END pc_crps707;
/
