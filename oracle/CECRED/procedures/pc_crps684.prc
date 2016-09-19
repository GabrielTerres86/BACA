CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS684 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                              ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: pc_crps684                        Antigo: ------
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jean Michel
   Data    : Setembro/2014                       Ultima atualizacao: 06/02/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Efetivar os resgates agendados para data futura.

   Alteracoes: 06/02/2015 - Implementado variavel(vr_contapli) para auxiliar
                            na listagem de de resgates para uma mesma aplicacao
                            (Jean Michel).
     ............................................................................. */

     DECLARE

       -- Definicao do tipo de registro de limites de credito
       TYPE typ_reg_resg_apli IS
       RECORD (nrdconta craprga.nrdconta%TYPE   -- Conta/dv: 
              ,nraplica craprga.nraplica%TYPE   -- Aplicação
              ,dtmvtolt craprga.dtmvtolt%TYPE   -- Data do Agendamento
              ,dtresgat craprga.dtresgat%TYPE   -- Data de Resgate
              ,vlresgat craprga.vlresgat%TYPE   -- Valor do Resgate: Se for um resgate não efetivado, obter o valor do resgate no campo craprga.vlresgat, e se for um resgate efetivado obter o valor no campo craplac.vllanmto no lançamento de resgate 
              ,idtiprgt VARCHAR2(20)            -- Tipo do Resgate:  (1 – Parcial / 2 – Total)
              ,dscritic crapcri.dscritic%TYPE   -- Crítica: Descrição conforme regra de validação onde foi abortado o resgate
              ,vlsldatl craprac.vlsldatl%TYPE   -- Saldo da Aplicação: Obter o valor no campo , após a atualização do saldo.);
              ,cdagenci crapage.nmextage%TYPE); -- COdigo do PA

       -- Definicao de registro de aplicacoes
       TYPE typ_apli_resgatadas IS
         TABLE OF typ_reg_resg_apli
         INDEX BY VARCHAR2(23);

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
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

       -- Seleciona registros de resgates
       CURSOR cr_craprga(pr_cdcooper IN craprga.cdcooper%TYPE
                        ,pr_dtregast IN craprga.dtresgat%TYPE
                        ,pr_idresgat IN craprga.idresgat%TYPE) IS

         SELECT
            rga.cdcooper
           ,rga.nrdconta
           ,rga.nraplica
           ,rga.nrseqrgt
           ,rga.dtresgat
           ,rga.dtmvtolt
           ,rga.vlresgat
           ,rga.idtiprgt
           ,rga.cdoperad
           ,rga.hrtransa
           ,rga.idresgat
           ,rga.idrgtcti
           ,rowid
         FROM
           craprga rga
         WHERE
               rga.cdcooper  = pr_cdcooper
           AND rga.dtresgat <= pr_dtregast
           AND rga.idresgat  = pr_idresgat
         ORDER BY
           rga.nrdconta;

       rw_craprga cr_craprga%ROWTYPE; 

       -- Seleciona registros de resgates com valores atualizados
       CURSOR cr_craprga2(pr_cdcooper IN craprga.cdcooper%TYPE
                         ,pr_nrdconta IN craprga.nrdconta%TYPE
                         ,pr_nraplica IN craprga.nraplica%TYPE) IS

         SELECT
            rga.cdcooper
           ,rga.nrdconta
           ,rga.nraplica
           ,rga.nrseqrgt
           ,rga.dtresgat
           ,rga.dtmvtolt
           ,rga.vlresgat
           ,rga.idtiprgt
           ,rga.cdoperad
           ,rga.hrtransa
           ,rga.idresgat
           ,rga.idrgtcti
           ,rowid
         FROM
           craprga rga
         WHERE
               rga.cdcooper = pr_cdcooper
           AND rga.nrdconta = pr_nrdconta 
           AND rga.nraplica = pr_nraplica;

       rw_craprga2 cr_craprga2%ROWTYPE;         

       -- Consulta de saldo de aplicacao
       CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE
                        ,pr_nrdconta IN craprac.nrdconta%TYPE
                        ,pr_nraplica IN craprac.nraplica%TYPE) IS

         SELECT
            rac.cdcooper
           ,rac.nrdconta
           ,rac.nraplica
           ,rac.vlsldatl
         FROM
           craprac rac
         WHERE
               rac.cdcooper = pr_cdcooper
           AND rac.nrdconta = pr_nrdconta
           AND rac.nraplica = pr_nraplica;
       rw_craprac cr_craprac%ROWTYPE;
       
       -- Consulta de PA
       CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS

         SELECT
            age.cdagenci || ' - ' || age.nmresage AS nmagenci
           ,age.cdagenci
           ,ass.nrdconta
         FROM
            crapass ass
           ,crapage age
         WHERE
              ass.cdcooper = pr_cdcooper
          AND ass.nrdconta = pr_nrdconta
          AND ass.cdcooper = age.cdcooper
          AND ass.cdagenci = age.cdagenci;

       rw_crapage cr_crapage%ROWTYPE;

       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

       -- Variaveis de excecao
       vr_exc_saida EXCEPTION;
       vr_exc_fimprg EXCEPTION;

       --Variaveis Locais
       vr_cdcritic crapcri.cdcritic%TYPE := 0;
       vr_dscritic crapcri.dscritic%TYPE := '';
       vr_tpcritic crapcri.cdcritic%TYPE := 0;

       vr_cdprogra VARCHAR2(10);
       vr_clobxml  CLOB;
       vr_dsarquiv VARCHAR2(200) := '/rl/crrl677.lst';
       vr_flgresga BOOLEAN := TRUE;
       vr_controle BOOLEAN := FALSE;

       vr_dscchave VARCHAR2(23) := NULL;
       vr_contapli NUMBER(6) := 0;

       vr_dsagenci VARCHAR2(3)  := NULL;
       vr_dsagenan VARCHAR2(3)  := NULL;
       vr_auxconta INT          := 0;

       -- Definicao de tabelas de aplicacoes resgatadas e nao resgatadas
       vr_tab_apli_nresg typ_apli_resgatadas;
       vr_tab_apli_resga typ_apli_resgatadas;

       --------------- Subrotinas --------------------------

       -- Subrotina para escrever texto na variável clob do xml
       PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
         BEGIN
           -- Escreve dados na variavel vr_clobxml que ira conter os dados do xml
           dbms_lob.writeappend(vr_clobxml, length(pr_des_dados), pr_des_dados);
         END;

     BEGIN

       --Atribuir o nome do programa que está executando
       vr_cdprogra:= 'CRPS684';

       -- Incluir nome do módulo logado
       GENE0001.pc_informa_acesso(pr_module => vr_cdprogra
                                 ,pr_action => NULL);

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se não encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se não encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois haverá raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

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

       -- ARQUIVO P/ GERACAO DO RELATORIO
       vr_dsarquiv := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                           ,pr_cdcooper => pr_cdcooper) || vr_dsarquiv;

       -- Leitura de registros de resgates
       FOR rw_craprga IN cr_craprga(pr_cdcooper         -- Codigo da cooperativa  
                                   ,rw_crapdat.dtmvtopr -- Data de resgate
                                   ,0)                  -- Resgate Não Efetivado
          LOOP

            -- Consulta de PA
            OPEN cr_crapage(pr_cdcooper => rw_craprga.cdcooper
                           ,pr_nrdconta => rw_craprga.nrdconta);

            FETCH cr_crapage INTO rw_crapage;

            -- Fecha cursor
            CLOSE cr_crapage;               

            -- Monta chave da pl table
            vr_dscchave := LPAD(rw_crapage.cdagenci,3,0) || LPAD(rw_crapage.nrdconta,8,0) || LPAD(rw_craprga.nraplica,6,0) || LPAD(vr_contapli,6,0);

            -- Contador para auxiliar no resgate de uma mesma aplicacao mais de uma vez
            vr_contapli := vr_contapli + 1;

            -- Procedure para efetuar resgate
            apli0005.pc_efetua_resgate(pr_cdcooper => rw_craprga.cdcooper
                                      ,pr_nrdconta => rw_craprga.nrdconta
                                      ,pr_nraplica => rw_craprga.nraplica
                                      ,pr_vlresgat => rw_craprga.vlresgat
                                      ,pr_idtiprgt => rw_craprga.idtiprgt
                                      ,pr_dtresgat => rw_craprga.dtresgat
                                      ,pr_nrseqrgt => rw_craprga.nrseqrgt
                                      ,pr_idrgtcti => rw_craprga.idrgtcti
                                      ,pr_tpcritic => vr_tpcritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);

            -- Consulta valores atualizados
            OPEN cr_craprga2(pr_cdcooper, rw_craprga.nrdconta, rw_craprga.nraplica);

            FETCH cr_craprga2 INTO rw_craprga2;

            IF cr_craprga2%NOTFOUND THEN
              CLOSE cr_craprga2;
              vr_dscritic := 'Erro ao consulta registro de resgate de aplicacao.';
              RAISE vr_exc_saida;
            ELSE
              CLOSE cr_craprga2;
            END IF;
                          
            -- Verifica se houve critica para efetuar o resgate                          
            IF vr_dscritic IS NOT NULL THEN

              IF vr_tpcritic = 1 THEN
                RAISE vr_exc_saida;
              END IF;
              
              -- Flag para verifica se houve critica
              vr_flgresga := FALSE;

              -- Insere dados do relatorio em pl table
              vr_tab_apli_nresg(vr_dscchave).cdagenci := rw_crapage.nmagenci;
              vr_tab_apli_nresg(vr_dscchave).nrdconta := rw_craprga.nrdconta;
              vr_tab_apli_nresg(vr_dscchave).nraplica := rw_craprga.nraplica;
              vr_tab_apli_nresg(vr_dscchave).dtmvtolt := rw_craprga.dtmvtolt;
              vr_tab_apli_nresg(vr_dscchave).dtresgat := rw_craprga.dtresgat;
              vr_tab_apli_nresg(vr_dscchave).dscritic := vr_dscritic;        

              IF rw_craprga.idtiprgt = 1 THEN
                vr_tab_apli_nresg(vr_dscchave).idtiprgt := 'PARCIAL';
                vr_tab_apli_nresg(vr_dscchave).vlresgat := rw_craprga.vlresgat;
              ELSE
                vr_tab_apli_nresg(vr_dscchave).idtiprgt := 'TOTAL';
                vr_tab_apli_nresg(vr_dscchave).vlresgat := rw_craprga2.vlresgat;
              END IF;

            ELSE
              -- Flag para verifica se houve critica
              vr_flgresga := TRUE;

              -- Insere dados do relatorio em pl table
              vr_tab_apli_resga(vr_dscchave).cdagenci := rw_crapage.nmagenci;
              vr_tab_apli_resga(vr_dscchave).nrdconta := rw_craprga.nrdconta;
              vr_tab_apli_resga(vr_dscchave).nraplica := rw_craprga.nraplica;
              vr_tab_apli_resga(vr_dscchave).dtmvtolt := rw_craprga.dtmvtolt;
              vr_tab_apli_resga(vr_dscchave).dtresgat := rw_craprga.dtresgat;
              vr_tab_apli_resga(vr_dscchave).vlresgat := rw_craprga2.vlresgat;
              vr_tab_apli_resga(vr_dscchave).dscritic := vr_dscritic;        

              IF rw_craprga.idtiprgt = 1 THEN
                vr_tab_apli_resga(vr_dscchave).idtiprgt := 'PARCIAL';
                vr_tab_apli_resga(vr_dscchave).vlresgat := rw_craprga.vlresgat;
              ELSE
                vr_tab_apli_resga(vr_dscchave).idtiprgt := 'TOTAL';
                vr_tab_apli_resga(vr_dscchave).vlresgat := rw_craprga2.vlresgat;
              END IF;
            END IF;
            
            -- Consulta saldo de aplicacao
            OPEN cr_craprac(pr_cdcooper => rw_craprga.cdcooper
                           ,pr_nrdconta => rw_craprga.nrdconta
                           ,pr_nraplica => rw_craprga.nraplica);

            FETCH cr_craprac INTO rw_craprac;               
            
            IF cr_craprac%NOTFOUND THEN
              CLOSE cr_craprac;
            ELSE
              CLOSE cr_craprac;
            END IF;

            -- Valor de saldo de aplicacao               
            vr_tab_apli_resga(vr_dscchave).vlsldatl := rw_craprac.vlsldatl;
                                           
          END LOOP;      

        -- INICIALIZAR O CLOB (XML)
        dbms_lob.createtemporary(vr_clobxml, TRUE);
        dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

        -- INICIO DO ARQUIVO XML
        pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');
          
        -- Atribuicao de primeiro indice
        vr_dscchave := vr_tab_apli_resga.first;

        IF vr_dscchave IS NOT NULL THEN

          vr_controle := TRUE;

          LOOP
            IF vr_tab_apli_resga(vr_dscchave).nraplica IS NOT NULL THEN

              vr_dsagenci := SUBSTR(vr_dscchave,0,3);        
   
              OPEN cr_crapage(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => vr_tab_apli_resga(vr_dscchave).nrdconta);

              FETCH cr_crapage INTO rw_crapage;

              CLOSE cr_crapage;  

              IF NVL(vr_dsagenan,0) <> vr_dsagenci AND
                 vr_auxconta <> 0 THEN 
                pc_escreve_xml('</resgatadas></dsagenci><dsagenci id="' || rw_crapage.nmagenci || '">');
                -- Abre tag pai de aplicacoes resgatadas mau sucedidas
                pc_escreve_xml('<resgatadas>');
                vr_auxconta := vr_auxconta + 1;
              ELSIF NVL(vr_dsagenan,0) = 0 THEN              
                pc_escreve_xml('<dsagenci id="' || rw_crapage.nmagenci || '">');
                -- Abre tag pai de aplicacoes resgatadas mau sucedidas
                pc_escreve_xml('<resgatadas>');
                vr_auxconta := vr_auxconta + 1;
              END IF;
                            
              -- Monta XML com resgates de aplicacoes bem sucedidos
              pc_escreve_xml('<nraplica id="' || vr_tab_apli_resga(vr_dscchave).nraplica || '">' ||          
                             '<nrdconta>' || gene0002.fn_mask_conta(vr_tab_apli_resga(vr_dscchave).nrdconta) || '</nrdconta>' ||
                             '<dtmvtolt>' || TO_CHAR(vr_tab_apli_resga(vr_dscchave).dtmvtolt,'dd/mm/RRRR') || '</dtmvtolt>' ||
                             '<dtresgat>' || TO_CHAR(vr_tab_apli_resga(vr_dscchave).dtresgat,'dd/mm/RRRR') || '</dtresgat>' ||
                             '<vlresgat>' || TO_CHAR(NVL(vr_tab_apli_resga(vr_dscchave).vlresgat,0),'fm999G999G990D00') || '</vlresgat>' ||
                             '<idtiprgt>' || vr_tab_apli_resga(vr_dscchave).idtiprgt || '</idtiprgt>' ||
                             '<vlsldatl>' || TO_CHAR(NVL(vr_tab_apli_resga(vr_dscchave).vlsldatl,0),'fm999G999G990D00') || '</vlsldatl></nraplica>');
                 
              vr_dsagenan := vr_dsagenci;
              
            END IF;
            -- Verifica se e o ultimo registro da pl table        
            IF vr_dscchave = vr_tab_apli_resga.last THEN
              EXIT;
            ELSE
             vr_dscchave := vr_tab_apli_resga.NEXT(vr_dscchave);
            END IF;
          END LOOP;
          -- Fecha tag pai de aplicacoes resgatadas bem sucedidas
          pc_escreve_xml('</resgatadas>');          
          pc_escreve_xml('</dsagenci>');

        END IF;        

        -- Limpa variaveis com PA
        vr_dsagenan := NULL;
        vr_dsagenci := NULL;
        vr_auxconta := 0;

        -- Atribuicao de primeiro indice
        vr_dscchave := vr_tab_apli_nresg.first;

        IF vr_dscchave IS NOT NULL THEN

          vr_controle := TRUE;

          LOOP
            IF vr_tab_apli_nresg(vr_dscchave).nraplica IS NOT NULL THEN
              vr_dsagenci := SUBSTR(vr_dscchave,0,3);
                 
              OPEN cr_crapage(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => vr_tab_apli_nresg(vr_dscchave).nrdconta);

              FETCH cr_crapage INTO rw_crapage;

              CLOSE cr_crapage;

              IF NVL(vr_dsagenan,0) <> vr_dsagenci AND
                 vr_auxconta <> 0 THEN 
                pc_escreve_xml('</naoresgatadas></dsagenci><dsagenci id="' || rw_crapage.nmagenci || '">');
                -- Abre tag pai de aplicacoes resgatadas mau sucedidas
                pc_escreve_xml('<naoresgatadas>');
                vr_auxconta := vr_auxconta + 1;
              ELSIF NVL(vr_dsagenan,0) = 0 THEN              
                pc_escreve_xml('<dsagenci id="' || rw_crapage.nmagenci || '">');
                -- Abre tag pai de aplicacoes resgatadas mau sucedidas
                pc_escreve_xml('<naoresgatadas>');
                vr_auxconta := vr_auxconta + 1;
              END IF;              
              
              -- Monta XML com resgates de aplicacoes bem sucedidos
              pc_escreve_xml('<nraplica id="' || vr_tab_apli_nresg(vr_dscchave).nraplica || '">' ||          
                             '<nrdconta>' || gene0002.fn_mask_conta(vr_tab_apli_nresg(vr_dscchave).nrdconta) || '</nrdconta>' ||
                             '<dtmvtolt>' || TO_CHAR(vr_tab_apli_nresg(vr_dscchave).dtmvtolt,'dd/mm/RRRR') || '</dtmvtolt>' ||
                             '<dtresgat>' || TO_CHAR(vr_tab_apli_nresg(vr_dscchave).dtresgat,'dd/mm/RRRR') || '</dtresgat>' ||
                             '<vlresgat>' || TO_CHAR(NVL(vr_tab_apli_nresg(vr_dscchave).vlresgat,0),'fm999G999G990D00') || '</vlresgat>' ||
                             '<idtiprgt>' || TRIM(vr_tab_apli_nresg(vr_dscchave).idtiprgt) || '</idtiprgt>' ||
                             '<vlsldatl>' || TO_CHAR(NVL(vr_tab_apli_nresg(vr_dscchave).vlsldatl,0),'fm999G999G990D00') || '</vlsldatl>' ||
                             '<dscritic>' || TRIM(vr_tab_apli_nresg(vr_dscchave).dscritic) || '</dscritic></nraplica>');
              
              vr_dsagenan := vr_dsagenci;
            END IF;     
            -- Verifica se e o ultimo registro da pl table        
            IF vr_dscchave = vr_tab_apli_nresg.last THEN
              EXIT;
            ELSE
             vr_dscchave := vr_tab_apli_nresg.NEXT(vr_dscchave);
            END IF;

          END LOOP;                

          -- Fecha tag pai de aplicacoes resgatadas mau sucedidas
          pc_escreve_xml('</naoresgatadas>');
          pc_escreve_xml('</dsagenci>');

        END IF;
        
        -- FECHA TAG PRINCIPAL DO ARQUIVO XML
        pc_escreve_xml('</raiz>');

        IF vr_controle THEN
          -- SOLICITACAO DO RELATORIO
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa
                                      pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                      pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                      pr_dsxml     => vr_clobxml,          --> Arquivo XML de dados
                                      pr_dsxmlnode => '/raiz/dsagenci',    --> Nó do XML para iteração
                                      pr_dsjasper  => 'crrl677.jasper',    --> Arquivo de layout do iReport
                                      pr_dsparams  => '',                  --> Array de parametros diversos
                                      pr_dsarqsaid => vr_dsarquiv,         --> Path/Nome do arquivo PDF gerado
                                      pr_flg_gerar => 'S',                 --> Gerar o arquivo na hora*
                                      pr_qtcoluna  => 132,                 --> Qtd colunas do relatório (80,132,234)
                                      pr_sqcabrel  => 1,                   --> Indicado de seq do cabrel
                                      pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)*
                                      pr_nmformul  => '132col',            --> Nome do formulário para impressão
                                      pr_nrcopias  => 1,                   --> Qtd de cópias
                                      pr_flappend  => 'N',                 --> Indica que a solicitação irá incrementar o arquivo
                                      pr_des_erro  => vr_dscritic);        --> Saída com erro

         -- VERIFICA SE OCORREU UMA CRITICA
         IF vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_saida;
         END IF;

       END IF;

       -- LIBERA A MEMORIA ALOCADA P/ VARIAVE CLOB
       dbms_lob.close(vr_clobxml);
       dbms_lob.freetemporary(vr_clobxml);
       -- FIM
       
       
       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_stprogra => pr_stprogra);

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
         pr_dscritic := 'Erro na procedure pc_crps684. '||sqlerrm;
         -- Efetuar rollback
         ROLLBACK;
         
     END;
   END pc_crps684;
/

