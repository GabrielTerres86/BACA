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
   Data    : Setembro/2016                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Realizado a efetivação de agendamentos de TEDs Sicredi

   Alteracoes:
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
   
    -- Busca do Cooperado pelo CPF
     CURSOR cr_crapttl(pr_nrcpfcgc NUMBER) IS
       SELECT cdcooper
             ,nrdconta             
         FROM crapttl
        WHERE nrcpfcgc = pr_nrcpfcgc;
    rw_crapttl cr_crapttl%ROWTYPE; 
   
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


     --Variaveis Locais
     vr_cdcritic     INTEGER;
     vr_cdprogra     VARCHAR2(10);
     vr_dscritic     VARCHAR2(4000);
     vr_nmarqlog     VARCHAR2(400) := 'prcctl_' || to_char(SYSDATE, 'RRRR') || to_char(SYSDATE,'MM') || to_char(SYSDATE,'DD') || '.log';
      

     --Variaveis de Excecao
     vr_exc_saida   EXCEPTION;
     vr_exc_email   EXCEPTION;
     vr_exc_fimprg  EXCEPTION;

     -- Diretorio e arquivos para processamento
     vr_datatual         DATE;
     vr_dir_sicredi_teds VARCHAR2(200);
     vr_dir_backup_teds  VARCHAR2(200);
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
     vr_nmprimtl    VARCHAR2(60);
     vr_flgexis_cpf BOOLEAN;
     vr_flgexis_cta BOOLEAN;
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
     vr_hasfound      BOOLEAN;
   
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
                                pr_ind_tipo_log => 2, --> erro tratado
                                pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                   ' - '|| vr_cdprogra ||' --> Iniciando processo de TEDs Sicredi',
                                pr_nmarqlog     => vr_nmarqlog);                                
     
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
                                      pr_ind_tipo_log => 2, --> erro tratado
                                      pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                         ' - '|| vr_cdprogra ||' --> Iniciando integracao do arquivo '||vr_idxtexto,
                                      pr_nmarqlog     => vr_nmarqlog); 

           -- Verificar se o arquivo já não foi processado (existe na tabela mesmo nome)
           vr_flgexis := 0;
           OPEN cr_nmarquiv(pr_nmarquiv => vr_idxtexto);
           FETCH cr_nmarquiv
            INTO vr_flgexis;
           CLOSE cr_nmarquiv;
           -- Se o arquivo já foi processado
           IF vr_flgexis = 1 THEN
             -- Gerar email ao Financeiro
             vr_dsassunt := 'TEDs SICREDI - ARQUIVO JA PROCESSADO';
             vr_dscorpoe := 'Arquivo '||vr_idxtexto||' já foi integrado anteriormente, favor verificar.';
             -- Mover o arquivo
             gene0001.pc_OScommand_Shell('mv '||vr_dir_sicredi_teds||'/'||vr_idxtexto||' '||vr_dir_sicredi_teds||'/ERRO_'||vr_idxtexto);
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

           -- Somente validar se o arquivo atual não é o primeiro
           IF vr_nrseqhead <> 1 THEN           
             -- Sequencia do arquivo deve ser imediamente posterior a ultima processada para a data
             vr_flgexis := 0;
             OPEN cr_sqarquiv(vr_dtarquiv,vr_nrseqhead-1);
             FETCH cr_sqarquiv
              INTO vr_flgexis;
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
                   vr_cdmotivo := 'Conta invalida = ' || substr(vr_dslinharq,70,13);
                   RAISE vr_exc_saida;
               END;

               -- Busca do CPF da TED
               BEGIN
                 vr_nrcpfcgc := substr(vr_dslinharq,209,14);
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdmotivo := 'CPF invalido = ' || substr(vr_dslinharq,209,14);
                   RAISE vr_exc_saida;
               END;

               -- Verificar a existencia do CPF na Cooperativa
               OPEN cr_crapttl(pr_nrcpfcgc => vr_nrcpfcgc);
               
               FETCH cr_crapttl INTO rw_crapttl;
               
               IF cr_crapttl%FOUND THEN
                 
                 -- Encontrou pelo menos 1 com CPF
                 vr_flgexis_cpf := true;
                 
               END IF;
               
               CLOSE cr_crapttl;
               
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
               
               -- Se não achou nenhuma conta ativa
               IF vr_cdcooper = 0 THEN
                 -- Gerar critica
                 vr_cdmotivo := '1 - Conta Destinataria  do Credito Encerrada.';
                 RAISE vr_exc_saida;
               END IF;

               -- Busca dados da origem da TED
               BEGIN
                 -- Separar conforme tipo da mensagem
                 IF substr(vr_dslinharq,1,2) = '05' THEN
                   vr_cdbandif := substr(vr_dslinharq,56,3);
                   vr_cdagedif := 0;
                   vr_nrctadif := 0;
                 ELSE
                   vr_cdbandif := substr(vr_dslinharq,42,3);
                   vr_cdagedif := substr(vr_dslinharq,45,4);
                   vr_nrctadif := substr(vr_dslinharq,51,13);
                 END IF;
                 vr_nrcpfdif := substr(vr_dslinharq,339,14);
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
                      SET qtcompln = qtcompln + 1
                        , vlinfocr = vlinfocr + vr_vloperac
                        , vlcompcr = vlcompcr + vr_vloperac
                        , nrseqdig = nrseqdig + 1
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
               BEGIN
                 INSERT INTO craplcm (dtmvtolt
                                     ,cdagenci
                                     ,cdbccxlt
                                     ,nrdolote
                                     ,nrdconta
                                     ,nrdctabb
                                     ,nrdctitg
                                     ,nrdocmto
                                     ,cdhistor
                                     ,vllanmto
                                     ,nrseqdig
                                     ,cdcooper
                                     ,hrtransa)
                              VALUES(rw_crapdat.dtmvtolt
                                    ,1
                                    ,100
                                    ,8482
                                    ,vr_nrdconta
                                    ,vr_nrdconta
                                    ,gene0002.fn_mask(vr_nrdconta,'99999999') -- nrdctitg
                                    ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                                    ,1787
                                    ,vr_vloperac
                                    ,rw_craplot.nrseqdig -- atualizado da LOTE acima
                                    ,vr_cdcooper
                                    ,to_char(SYSDATE,'sssss'));
               EXCEPTION
                 WHEN OTHERS THEN
                   vr_cdmotivo := 'Erro ao criar Trasnferencia em C/C: '||SQLERRM;
                   RAISE vr_exc_saida;
               END;

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
                                        ,pr_nrdconta => vr_nrdconta
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
                                          pr_ind_tipo_log => 2, --> erro tratado
                                          pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                             ' - '|| vr_cdprogra ||' --> TED para Conta '||vr_nrdconta||' no valor de '
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
                 sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
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
                                          ,pr_dsmotivo => ''
                                          ,pr_cdagenci => 0
                                          ,pr_nrdcaixa => 0
                                          ,pr_cdoperad => '1'
                                          ,pr_nrispbif => vr_nrispbif
                                          ,pr_cdifconv => 1
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                 --> Gerar log
                 btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                            pr_ind_tipo_log => 2, --> erro tratado
                                            pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                               ' - '|| vr_cdprogra ||' --> TED para conta '||vr_nrdconta||' com erro --> '||vr_cdmotivo,
                                            pr_nmarqlog     => vr_nmarqlog);                                
                                          
               WHEN no_data_found THEN
                 -- Finalizou a leitura
                 EXIT;
               WHEN OTHERS THEN
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

           END IF;

           -- Ao final do processamento do arquivo, devemos movê-lo conforme estrutura:
           -- Estrutura base: /usr/connect/sicredi/ted
           -- Sub-diretório: /RRRR
           -- Sub-diretório: /MM.RRRR
           -- Sub-diretório: /DD.MM.RRRR

           -- Montar caminho completo do diretório:
           vr_dir_backup_teds := vr_dir_sicredi_teds||'/'||to_char(vr_dtarquiv,'RRRR')
                              ||'/'||to_char(vr_dtarquiv,'MM')||'.'||to_char(vr_dtarquiv,'RRRR')
                              ||'/'||to_char(vr_dtarquiv,'DD')||'.'||to_char(vr_dtarquiv,'MM')||'.'||to_char(vr_dtarquiv,'RRRR');

           -- Primeiro garantimos que o diretorio exista
           IF NOT gene0001.fn_exis_diretorio(vr_dir_backup_teds) THEN
             -- Efetuar a criação do mesmo
             gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir -p '||vr_dir_backup_teds
                                        ,pr_typ_saida   => vr_typ_saida
                                        ,pr_des_saida   => vr_des_saida);

             --Se ocorreu erro dar RAISE
             IF vr_typ_saida = 'ERR' THEN
               vr_dscritic := 'Nao foi possivel criar diretorios para mover os arquivos processados.';
               RAISE vr_exc_saida;
             END IF;           
            
           END IF;

           --Move o arquivo XML fisico de envio
           GENE0001.pc_OScommand (pr_typ_comando => 'S'
                                 ,pr_des_comando => 'mv '||vr_dir_sicredi_teds||'/'||rtrim(vr_idxtexto,gene0001.fn_extensao_arquivo(vr_idxtexto))||'* '||vr_dir_backup_teds || ' 2> /dev/null'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_dscritic);
                                 
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida = 'ERR' THEN
             RAISE vr_exc_saida;
           END IF;
             
           --> Gerar log
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                      pr_ind_tipo_log => 2, --> erro tratado
                                      pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                         ' - '|| vr_cdprogra ||' --> Encerramento do processo do arquivo '||vr_idxtexto,
                                      pr_nmarqlog     => vr_nmarqlog);                                 

           -- Efetuar gravação das alterações no banco a cada arquivo
           COMMIT;
         EXCEPTION
           WHEN no_data_found THEN
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
             -- Gravar para envio do e-mail
             COMMIT;
             -- Se foi solicitado encerramento
             IF vr_flgencer THEN
               EXIT;
             END IF;
           WHEN vr_exc_saida THEN
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
                                pr_ind_tipo_log => 2, --> erro tratado
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
       -- Efetuar retorno do erro não tratado
       pr_cdcritic := 0;
       pr_dscritic := 'Erro na procedure pc_crps707. '||sqlerrm;

       -- Efetuar rollback
       ROLLBACK;

   END;

 END pc_crps707;
/
