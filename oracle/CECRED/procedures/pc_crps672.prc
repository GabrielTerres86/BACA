CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS672 ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                          ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                          ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                          ,pr_cdoperad IN crapnrc.cdoperad%TYPE   --> Código do operador
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* ..........................................................................

       Programa: pc_crps672
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Lunelli
       Data    : Abril/2014.                     Ultima atualizacao: 02/01/2017

       Dados referentes ao programa:

       Frequencia: Diário.
       Objetivo  : Atende a solicitacao 01, Ordem 36.
                   Tratar arquivo de retorno da Solicitação de Cartão (Bancoob/CABAL).
                   Relatório crrl676 - Rejeições Processamento Arq. Retorno

       Alteracoes: 22/08/2014 - Ajustes para validação do processamento do arquivo,
                               alteração para buscar leitura do arquivo conforme cadastro.(Odirlei-AMcom)
                               
                   27/08/2014 - Realizar commit a cada processamento de arquivo(Odirlei/Amcom)
                   
                   08/09/2014 - Retirar código da Versão temporária, devido a solicitação via 
                                chamado SD 197307 (Renato - Supero)
                                
                   25/09/2014 - Incluir regra para buscar cartão em uso no cursor
                                cr_crawcrd_cdgrafin  ( Renato - Supero )
                                
                   30/09/2014 - Alterado as regras para tratamento de arquivo e
                                ajustada ordenação do relatório de rejeitados
                                (Renato - Supero)
                                
                   14/10/2014 - Alterações no formato do relatório conforme SD 204500 (Vanessa)

                   04/11/2014 - Quando inserir um novo CRAWCRD, deverá incluir o valor
                                do flgprcrd, conforme o valor do cartão encerrado ( Renato - Supero )
                                
                   11/11/2014 - Ajustar programa para gravar as datas relacionadas a solicitação
                                de segunda via de cartão, conforme chamado 217188 e ajuste nos 
                                selects do grupo de afinidade, afim de filtrar apenas por 
                                administradoras do Bancoob ( Renato - Supero )
                                
                   13/11/2014 - Alteração para não exibir as criticas menores que 10 e maiores 
                                que 900 (Vanessa)
                                
                   10/03/2015 - Alterado para gravar corretamente as datas de solicitação de 
                                segunda via de cartão, conforme chamado 251387 ( Renato - Supero )
                                
                   21/07/2015 - Realizado ajuste para ignorar linhas com crítica, onde a conta(posição 337)
                                esteja com valor igual a zero. Alteração realizada devido a erros ocorridos
                                no processo batch. (Renato - Supero)
                                
                   15/10/2015 - Desenvolvimento do projeto 126. (James)
                   
                   02/12/2015 - Ajuste para mostrar a Administradora no relatorio. (James)
                   
                   07/12/2015 - Resolução do chamado 370195.
                                Ajuste para gravar o codigo da administradora para os cartoes solicitados apartir do
                                Bancoob. (James)
                                
                   15/02/2016 - Ajuste para gerar no relatorio de criticas 676 retorno de solicitacao
                                criticado que vier com os dados do CNPJ. (Chamado 389699) - (Fabricio)
                                
                   10/03/2016 - Feita a troca de log do batch para o proc_message conforme
                                solicitado no chamado 405441 (Kelvin).
                                
                   12/05/2016 - Ajustado situacao de Cancelado para 6 no cursor cr_crawcrd_cdgrafin_conta
                                pois esse eh o indicador de cartao cancelado quando trata-se de
                                Cartao Cecred (Bancoob). (Chamado 433197 entre outros...) - (Fabricio)
                                
                   22/06/2016 - Ajuste no ELSE que verifica a existencia de registro na leitura do
                                cursor cr_crapacb para nao gerar mais RAISE, mas sim, gravar log
                                e continuar processando o arquivo. (Fabricio)
                                
                   29/06/2016 - Ajuste no cursor cr_crawcrd_cdgrafin_conta para contemplar a busca
                                tanto por cartoes Bloqueados quanto Cancelados (insitcrd = 5,6).
                                (Chamados 478655, 478680 entre outros...) - (Fabricio)
                                
                   14/07/2016 - Ajustado a identificacao dos dados da conta e controle na leitura do
                                numero da conta quando o valor recebido eh zero
                                (Douglas - Chamado 465010, 478018)

                   04/10/2016 - Ajustado para gravar o nome da empresa do plastico quando criar uma
                                nova proposta de cartao (Douglas - Chamado 488392)
                                
                   10/10/2016 - Ajuste para nao voltar para Aprovado uma solicitacao que
                                retornar com critica 80 do Bancoob (pessoa ja tem cartao nesta conta).
                                (Chamado 532712) - (Fabrício)

				           01/11/2016 - Ajustes quando ocorre integracao de cartao via Upgrade/Downgrade.
                                (Chamado 532712) - (Fabricio)
                                
                   11/11/2016 - Adicionado validação de CPF do primeiro cartão da administradora
                                para que os cartões solicitados como reposição também tenham a mesma
                                flag de primeiro cartão (Douglas - Chamado 499054 / 541033)
                                
                   24/11/2016 - Ajuste para alimentar o campo de indicador de funcao debito (flgdebit)
                                com a informacao que existe na linha do arquivo referente a
                                funcao habilitada ou nao. (Fabricio)
                              - Quando tipo de operacao for 10 (desbloqueio) e for uma reposicao de cartao,
                                chamar a procedure atualiza_situacao_cartao para cancelar o cartao
                                anterior. (Chamado 559710) - (Fabricio)
                                
                   05/12/2016 - Correcao no cursor cr_crapcrd para buscar cartoes atraves do indice da tabela
                                e inclusao da validacao da existencia de cartoes sem proposta gerando log 
                                no proc_message. SD 569619 (Carlos Rafael Tanholi)
                                
                   02/01/2017 - Ajuste na leitura dos registros de cartoes ja existentes.
                                (Fabricio)
    ............................................................................ */

    DECLARE
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS672';       --> Código do programa
      vr_dsdireto   VARCHAR2(200);                                     --> Caminho
      vr_dsdirarq   VARCHAR2(200);                                     --> Caminho e nome do arquivo      
      vr_direto_connect   VARCHAR2(200);                               --> Caminho CONNECT
      vr_dsdireto_rlnsv  VARCHAR2(200);                                --> Caminho /rlnsv
      vr_nmrquivo   VARCHAR2(200);                                     --> Nome do arquivo
      vr_nmarquiv   VARCHAR2(4000);                                    --> Nome do(s) arqs em Diretório
      vr_des_text   VARCHAR2(2000);                                    --> Conteúdo da Linha do Arquivo
      vr_contador   NUMBER:= 0;                                        --> Conta qtd. arquivos
      vr_ind_arquiv utl_file.file_type;                                --> declarando handle do arquivo
      vr_tipooper   VARCHAR2(4)     := 0;                              --> Tp. Operac
      vr_nroperac   NUMBER          := 0;                              --> Nr. Operação
      vr_cdgrafin   NUMBER          := 0;                              --> Cd. Grupo de Afinidade
      vr_nrdconta   NUMBER          := 0;                              --> Nr. Conta a Debitar
      vr_cdagebcb   NUMBER          := 0;                              --> Cd. Agencia do Bancoob da Cooperativa
      vr_cdcooper   NUMBER          := 0;                              --> Cd. Coopertaiva identificada
      vr_nrcanven   VARCHAR2(200)   := 0;                              --> Nr. Canal de Venda (PA)
      vr_dddebito   NUMBER          := 0;                              --> Dia Déb. em Conta-corrente
      vr_comando    VARCHAR2(2000);                                    --> Comando UNIX para Mover arquivo lido
      vr_nrseqarq   INTEGER;                                           --> Sequencia de Arquivo
      vr_nrseqarq_max INTEGER := 0;                                    --> Maior Sequencia de Arquivo
      vr_vllimcrd   crawcrd.vllimcrd%TYPE;                             --> Valor de limite de credito
      vr_tpdpagto   NUMBER          := 0;                              --> Tp de Pagto do cartão
      vr_flgdebcc   NUMBER          := 0;                              --> flg para debitar em conta
      vr_flgprcrd   NUMBER          := 0;                              --> Primeiro cartão dessa Modalidade
      vr_nmextttl   crapttl.nmextttl%TYPE;                             --> Nome Titular
      vr_vlsalari   crapttl.vlsalari%TYPE;                             --> Salario
      vr_dtnasccr   crapass.dtnasctl%TYPE;                             --> Dt. Nasc.
      vr_nrctrcrd   crawcrd.nrctrcrd%TYPE;                             --> Nr. Contrato
      vr_nrseqcrd   crawcrd.nrseqcrd%TYPE;                             --> Nr. Sequencial do Contrato para o Bancoob
      vr_nrdctitg   NUMBER;
      vr_nmtitcrd   VARCHAR2(50);                                      --> Nome do Titular do cartão
      vr_dtentr2v   DATE;                                              --> Data de entrada do registro de segunda via
      -- Tratamento de registros do arquivo
      vr_nrctatp1   NUMBER          := 0;                              --> Número da conta do registro Tipo 1
      vr_nrctatp2   NUMBER          := 0;                              --> Número da conta do registro Tipo 2
      vr_cdlimcrd   crawcrd.cdlimcrd%TYPE;                             --> Codigo da linha do valor de credito
      vr_flgdebit   crawcrd.flgdebit%TYPE;                             --> Verifica se o cartao possui funcao de debito habilitada

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      PLS_INTEGER;
      vr_dscritic      VARCHAR2(4000);
      vr_typ_saida     VARCHAR2(4000);
      vr_des_erro      VARCHAR2(3);

      -- Variáveis locais do bloco
      vr_xml_clobxml       CLOB;
      vr_xml_lim_cartao    CLOB;
      vr_xml_des_erro      VARCHAR2(4000);
      vr_pa_anterior       NUMBER          := 0;
      vr_pa_proximo        BOOLEAN; 

      -- Definicao do tipo de arquivo para processamento
      TYPE typ_tab_nmarquiv IS
       TABLE OF VARCHAR2(100)
       INDEX BY BINARY_INTEGER;

      -- Vetor para armazenar os arquivos para processamento
      vr_vet_nmarquiv typ_tab_nmarquiv;

       -- Definicao do vetor com os códigos e os nomes das solicitações
        TYPE typ_vet_nmtipsol IS
          TABLE OF VARCHAR2(150)
          INDEX BY BINARY_INTEGER;
        
        vr_vet_nmtipsol  typ_vet_nmtipsol;

      ------------------------------- CURSORES ---------------------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.cdagebcb
              ,cop.dsdircop
              ,cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Busca as cooperativas
      CURSOR cr_crapcop_todas IS
        SELECT cop.nmrescop
              ,cop.cdagebcb
              ,cop.dsdircop
              ,cop.cdcooper
          FROM crapcop cop
          WHERE cop.cdcooper <> 3 ;
      rw_crapcop_todas cr_crapcop_todas%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;

     -- Cursor para retornar cooperativa com base na conta da central
      CURSOR cr_crapcop_cdagebcb (pr_cdagebcb IN crapcop.cdagebcb%TYPE) IS
      SELECT cop.cdcooper,
             cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdagebcb = pr_cdagebcb;
      rw_crapcop_cdagebcb cr_crapcop_cdagebcb%ROWTYPE;

      -- cursor para Grupo de Afinidade
      CURSOR cr_crapacb (pr_cdgrafin IN crapacb.cdgrafin%TYPE) IS
      SELECT acb.cdadmcrd
        FROM crapacb acb
       WHERE acb.cdgrafin = pr_cdgrafin;
      rw_crapacb cr_crapacb%ROWTYPE;

      -- Busca status de retorno do arquivo
      CURSOR cr_crapscb IS
        SELECT scb.flgretpr,
               scb.nrseqarq,
               scb.dsarquiv,
               scb.dsdirarq,
               scb.rowid
          FROM crapscb scb
         WHERE scb.tparquiv = 7;-- CCR3
      rw_crapscb cr_crapscb%ROWTYPE;

      -- cursor para Rejeições no Processamento do Arq. de Retorno CABAL (CCR3)
      CURSOR cr_craprej (pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                         ,pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT rej.cdcooper
              ,rej.cdagenci
              ,age.nmextage
              ,rej.nrdconta
              ,rej.nrdocmto
              ,DECODE(NVL(to_number(substr(rej.cdpesqbb,0,19)),0),0,NULL,substr(rej.cdpesqbb,0,19)) cdpesqbb
              ,rej.nrdctitg nrdctitg            
              ,LISTAGG(rej.cdcritic || '-' || NVL(crc.dscritic, 'CRITICA NAO CADASTRADA'), ',') WITHIN GROUP (ORDER BY cdcritic) cdcritic
              ,SUBSTR(LISTAGG (substr(rej.cdpesqbb,20,23), ', ') WITHIN GROUP (ORDER BY substr(rej.cdpesqbb,20,23) ),0,23) nmtitcrd 
              ,NVL(to_number(substr(rej.cdpesqbb,43,2)),0) AS cdtipope

        FROM craprej rej
                
        INNER JOIN crapage age ON
                   age.cdcooper = rej.cdcooper
              AND  age.cdagenci = rej.cdagenci 
        
        LEFT JOIN crapcrc crc ON 
                  crc.cdcodigo = rej.cdcritic
              
         
        WHERE rej.dshistor = 'CCR3'
          AND rej.cdcritic > 10 
          AND rej.cdcritic < 900  
          AND rej.dtmvtolt = pr_dtmvtolt
          AND rej.cdcooper = pr_cdcooper                  
                  
       GROUP BY rej.cdcooper
                ,rej.cdagenci
                ,age.nmextage
                ,rej.nrdconta
                ,rej.nrdocmto
                ,DECODE(NVL(to_number(substr(rej.cdpesqbb,0,19)),0),0,NULL,substr(rej.cdpesqbb,0,19))
                ,rej.nrdctitg
                ,crc.dscritic
                ,to_number(substr(rej.cdpesqbb,43,2))                          
        ORDER BY rej.cdagenci, rej.nrdconta;


      rw_craprej cr_craprej%ROWTYPE;
      
      -- cursor para busca de proposta de cartão
      CURSOR cr_crawcrd (pr_cdcooper IN crawcrd.cdcooper%TYPE,
                         pr_nrdconta IN crawcrd.nrdconta%TYPE,
                         pr_nrcpftit IN crawcrd.nrcpftit%TYPE,
                         pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE,
                         pr_rowid    IN ROWID := NULL) IS
      SELECT pcr.cdcooper
            ,pcr.nrdconta
            ,pcr.nrcrcard
            ,pcr.nrcpftit
            ,pcr.nmtitcrd
            ,pcr.dddebito
            ,pcr.cdlimcrd
            ,pcr.dtvalida
            ,pcr.nrctrcrd
            ,pcr.cdmotivo
            ,pcr.nrprotoc
            ,pcr.cdadmcrd
            ,pcr.tpcartao
            ,pcr.nrcctitg
            ,pcr.vllimcrd
            ,pcr.flgctitg
            ,pcr.dtmvtolt
            ,pcr.nmextttl
            ,pcr.flgprcrd
            ,pcr.tpdpagto
            ,pcr.flgdebcc
            ,pcr.tpenvcrd
            ,pcr.vlsalari
            ,pcr.insitcrd
            ,pcr.dtnasccr
            ,pcr.nrdoccrd
            ,pcr.dtcancel
            ,pcr.flgdebit
            ,pcr.nmempcrd
            ,pcr.rowid
        FROM crawcrd pcr
       WHERE pcr.cdcooper = pr_cdcooper  AND
             pcr.nrdconta = pr_nrdconta  AND
             pcr.nrcpftit = pr_nrcpftit  AND
             pcr.cdadmcrd = pr_cdadmcrd  AND
             (pcr.rowid <> pr_rowid OR pr_rowid IS NULL) AND
             pcr.dtcancel IS NULL;
      rw_crawcrd cr_crawcrd%ROWTYPE;

      -- cursor para busca de proposta de cartões do bancoob por conta
      -- para verificar se é o primeiro cartão bancoob adquirido pela empresa
      -- desta administradora
      CURSOR cr_crawcrd_flgprcrd (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                  pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                  pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE) IS
      SELECT pcr.flgprcrd
            ,pcr.nrcpftit
        FROM crawcrd pcr
       WHERE pcr.cdcooper = pr_cdcooper AND
             pcr.nrdconta = pr_nrdconta AND
             pcr.cdadmcrd = pr_cdadmcrd AND
             pcr.flgprcrd = 1;
      rw_crawcrd_flgprcrd cr_crawcrd_flgprcrd%ROWTYPE;

      CURSOR cr_crawcrd_rowid (pr_rowid IN ROWID) IS
      SELECT pcr.cdcooper
            ,pcr.nrdconta
            ,pcr.nrcrcard
            ,pcr.nrcpftit
            ,pcr.nmtitcrd
            ,pcr.dddebito
            ,pcr.cdlimcrd
            ,pcr.dtvalida
            ,pcr.nrctrcrd
            ,pcr.cdmotivo
            ,pcr.nrprotoc
            ,pcr.cdadmcrd
            ,pcr.tpcartao
            ,pcr.nrcctitg
            ,pcr.vllimcrd
            ,pcr.flgctitg
            ,pcr.dtmvtolt
            ,pcr.nmextttl
            ,pcr.flgprcrd
            ,pcr.tpdpagto
            ,pcr.flgdebcc
            ,pcr.tpenvcrd
            ,pcr.vlsalari
            ,pcr.insitcrd
            ,pcr.dtnasccr
            ,pcr.nrdoccrd
            ,pcr.dtcancel
            ,pcr.flgdebit
            ,pcr.nmempcrd
            ,pcr.rowid
        FROM crawcrd pcr
       WHERE ROWID = pr_rowid;

      -- cursor para busca de cartão
      CURSOR cr_crapcrd (pr_cdcooper IN crapcrd.cdcooper%TYPE,
                         pr_nrdconta IN crapcrd.nrdconta%TYPE,
                         pr_nrcrcard IN crapcrd.nrcrcard%TYPE) IS
      SELECT crd.nrcrcard
            ,crd.rowid
        FROM crapcrd crd
       WHERE crd.cdcooper = pr_cdcooper  AND
             crd.nrdconta = pr_nrdconta  AND
             crd.nrcrcard = pr_nrcrcard  AND
             crd.dtcancel IS NULL;
      rw_crapcrd cr_crapcrd%ROWTYPE;

      -- cursor para cooperado PF
      CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE,
                         pr_nrdconta IN crapttl.nrdconta%TYPE,
                         pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
      SELECT ttl.idseqttl
            ,ttl.nrcpfcgc
            ,ttl.vlsalari
            ,ttl.nmextttl
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper AND
             ttl.nrdconta = pr_nrdconta AND
             ttl.nrcpfcgc = pr_nrcpfcgc;
      rw_crapttl cr_crapttl%ROWTYPE;
      
      -- Buscar o código do grupo de afinidade, ignorando os parametros
      -- que estejam sendo passados como null
      CURSOR cr_crawcrd_cdgrafin(pr_cdcooper IN crawcrd.cdcooper%TYPE
                                ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                                ,pr_nrcpftit IN crawcrd.nrcpftit%TYPE
                                ,pr_insitcrd IN crawcrd.insitcrd%TYPE
                                ,pr_flgprcrd IN crawcrd.flgprcrd%TYPE) IS 
        SELECT pcr.cdadmcrd
             , pcr.dddebito
             , pcr.vllimcrd
             , pcr.tpdpagto
             , pcr.flgdebcc
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND (pcr.nrcctitg = pr_nrcctitg OR pr_nrcctitg IS NULL)
           AND (pcr.nrcpftit = pr_nrcpftit OR pr_nrcpftit IS NULL)
           AND pcr.dtcancel IS NULL
           AND pcr.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
           -- Se o parametro vir nulo, deve considerar as situações 3 e 4
           AND (pcr.insitcrd = pr_insitcrd OR (pr_insitcrd IS NULL AND pcr.insitcrd IN (3,4)))
           AND (pcr.flgprcrd = pr_flgprcrd OR pr_flgprcrd IS NULL);
      
      CURSOR cr_crawcrd_cdgrafin_conta(pr_cdcooper IN crawcrd.cdcooper%TYPE
                                      ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                                      ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                                      ,pr_dtmvtolt IN crawcrd.dtcancel%TYPE) IS 
        SELECT max(pcr.dtpropos) dtpropos,
               pcr.cdadmcrd,
               pcr.dddebito,
               pcr.vllimcrd,
               pcr.tpdpagto,
               pcr.flgdebcc
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND pcr.nrcctitg = pr_nrcctitg
           AND (pcr.dtcancel = pr_dtmvtolt OR pcr.insitcrd IN (5,6))
           AND pcr.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
           AND pcr.flgprcrd = 1
      GROUP BY pcr.cdadmcrd,
               pcr.dddebito,
               pcr.vllimcrd,
               pcr.tpdpagto,
               pcr.flgdebcc;
      rw_crawcrd_cdgrafin_conta cr_crawcrd_cdgrafin_conta%ROWTYPE;
               
      -- Buscar cartão liberado que tenha um outro cancelado na mesma data ( Ou seja: Up/Downgrade)
      CURSOR cr_crawcrd_cancel(pr_cdcooper IN crawcrd.cdcooper%TYPE
                              ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                              ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                              ,pr_insitcrd IN crawcrd.insitcrd%TYPE
                              ,pr_dtmvtolt IN crawcrd.dtcancel%TYPE ) IS
        SELECT pcr.cdadmcrd
             , pcr.dddebito
             , pcr.vllimcrd
             , pcr.tpdpagto
             , pcr.flgdebcc
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND pcr.nrcctitg = pr_nrcctitg
           AND pcr.insitcrd = pr_insitcrd 
           AND pcr.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob 
           AND EXISTS (SELECT 1
                         FROM crawcrd t
                        WHERE t.cdcooper = pcr.cdcooper
                          AND t.nrdconta = pcr.nrdconta
                          AND t.nrcctitg = pcr.nrcctitg
                          AND t.insitcrd = 6 -- Encerrado
                          AND t.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
                          AND t.dtcancel = pr_dtmvtolt);
      
      -- Buscar o código do grupo de afinidade de cartão solicitado, em uso ou liberado
      CURSOR cr_crawcrd_ativo(pr_cdcooper IN crawcrd.cdcooper%TYPE
                             ,pr_nrdconta IN crawcrd.nrdconta%TYPE
                             ,pr_nrcctitg IN crawcrd.nrcctitg%TYPE
                             ,pr_nrcpftit IN crawcrd.nrcpftit%TYPE
                             ,pr_rowid    IN ROWID) IS 
        SELECT pcr.cdadmcrd
             , pcr.dddebito
             , pcr.vllimcrd
             , pcr.tpdpagto
             , pcr.flgdebcc
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND pcr.nrcctitg = pr_nrcctitg
           AND pcr.nrcpftit = pr_nrcpftit
           AND pcr.rowid <> pr_rowid
           AND pcr.dtcancel IS NULL
           AND pcr.cdadmcrd BETWEEN 10 AND 80 -- Apenas bancoob
           AND pcr.insitcrd IN (2,3,4);
      
      -- cursor para encontrar dados de associado
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                         pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.nmprimtl
            ,ass.inpessoa
            ,ass.dtnasctl
            ,ass.cdagenci
            ,crapage.nmextage
        FROM crapass ass
        JOIN crapage
          ON crapage.cdcooper = ass.cdcooper
         AND crapage.cdagenci = ass.cdagenci
       WHERE ass.cdcooper = pr_cdcooper AND
             ass.nrdconta = pr_nrdconta ;
      rw_crapass cr_crapass%ROWTYPE;

      -- cursor para encontrar dados de representanta
      CURSOR cr_crapass_avt (pr_cdcooper IN crapass.cdcooper%TYPE,
                             pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.nmprimtl
            ,ttl.vlsalari
            ,ass.cdagenci
        FROM crapass ass,
             crapttl ttl
       WHERE ass.cdcooper = pr_cdcooper  AND
             ass.nrcpfcgc = pr_nrcpfcgc  AND
             ttl.cdcooper = ass.cdcooper AND
             ttl.nrcpfcgc = ass.nrcpfcgc;
      rw_crapass_avt cr_crapass_avt%ROWTYPE;

      CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE,
                         pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT jur.dtiniatv
            ,jur.nrinsest
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper AND
             jur.nrdconta = pr_nrdconta ;
      rw_crapjur cr_crapjur%ROWTYPE;

      -- cursor para encontrar dados do avalista de PJ
      CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%TYPE,
                         pr_nrdconta IN crapavt.nrdconta%TYPE,
                         pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
      SELECT avt.nrdconta
            ,avt.tpdocava
            ,avt.nmdavali
            ,avt.cdestcvl
            ,avt.nrcpfcgc
            ,avt.nrdocava
            ,avt.cdoeddoc
            ,avt.cdufddoc
            ,avt.dtnascto
            ,DECODE(avt.cdsexcto,1,'2',2,'1','0') sexbancoob
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper AND
             avt.nrdconta = pr_nrdconta AND
             avt.nrcpfcgc = pr_nrcpfcgc ;
      rw_crapavt cr_crapavt%ROWTYPE;
      
      -- Buscar informação de cartão verificando se o mesmo já foi cancelado
      CURSOR cr_crawcrd_encerra(pr_cdcooper     crawcrd.cdcooper%TYPE
                               ,pr_nrdconta     crawcrd.nrdconta%TYPE
                               ,pr_nrcctitg     crawcrd.nrcctitg%TYPE
                               ,pr_nrcrcard     crawcrd.nrcrcard%TYPE) IS
        SELECT 1
          FROM crawcrd pcr
         WHERE pcr.cdcooper = pr_cdcooper  
           AND pcr.nrdconta = pr_nrdconta  
           AND pcr.nrcctitg = pr_nrcctitg
           AND pcr.nrcrcard = pr_nrcrcard
           AND pcr.insitcrd = 6;
      rw_crawcrd_encerra   cr_crawcrd_encerra%ROWTYPE;
      
      -- Busca as informacoes de Cartao do tipo Outros pela sequencia
      CURSOR cr_crawcrd_outros(pr_cdcooper crawcrd.cdcooper%TYPE
                              ,pr_nrseqcrd crawcrd.nrseqcrd%TYPE) IS
        SELECT crawcrd.nrdconta
          FROM crawcrd
         WHERE crawcrd.cdcooper = pr_cdcooper  
           AND crawcrd.cdadmcrd >= 10
           AND crawcrd.cdadmcrd <= 80
           AND crawcrd.nrseqcrd = pr_nrseqcrd
           AND ROWNUM = 1;
      rw_crawcrd_outros cr_crawcrd_outros%ROWTYPE;
      
      -- Busca as informacoes de Cartao do tipo Outros pela conta cartao
      CURSOR cr_crawcrd_outros_nrcctitg(pr_cdcooper crawcrd.cdcooper%TYPE
                                       ,pr_nrcctitg crawcrd.nrcctitg%TYPE) IS
      
      SELECT crawcrd.nrdconta
        FROM crawcrd
       WHERE crawcrd.cdcooper = pr_cdcooper
         AND crawcrd.cdadmcrd >= 10
         AND crawcrd.cdadmcrd <= 80
         AND crawcrd.nrcctitg = pr_nrcctitg
         AND ROWNUM = 1;
      rw_crawcrd_outros_nrcctitg cr_crawcrd_outros_nrcctitg%ROWTYPE;
      
      -- Tabela de Limite de Credito
      CURSOR cr_craptlc(pr_cdcooper craptlc.cdcooper%TYPE,
                        pr_cdadmcrd craptlc.cdadmcrd%TYPE,
                        pr_vllimcrd craptlc.vllimcrd%TYPE) IS
        SELECT craptlc.cdlimcrd
          FROM craptlc
         WHERE craptlc.cdcooper = pr_cdcooper
           AND craptlc.cdadmcrd = pr_cdadmcrd
           AND craptlc.vllimcrd = pr_vllimcrd
           AND craptlc.dddebito = 0           
           AND ROWNUM = 1;
      rw_craptlc cr_craptlc%ROWTYPE;
      
      -------------------- PROCEDIMENTOS INTERNOS ------------------------------
      /* Função para mascarar do numero do cartao */
      FUNCTION fn_mask_cartao(pr_nrcrcard VARCHAR2) RETURN VARCHAR2 IS
      BEGIN
        RETURN SUBSTR(pr_nrcrcard, 1, 4) || '.****.****.' || SUBSTR(pr_nrcrcard, length(pr_nrcrcard) -3, 4);
      END;
                   
      PROCEDURE altera_sit_cartao_aprovado(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                           pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                           pr_nrseqcrd IN crawcrd.nrseqcrd%TYPE)IS
        -- Atualiza registro de Proposta de Cartão de Crédito novamente para aprovado
        BEGIN
          UPDATE crawcrd
             SET insitcrd = 1 -- Aprovado
           WHERE crawcrd.cdcooper = pr_cdcooper
             AND crawcrd.nrdconta = pr_nrdconta
             --AND crawcrd.nrctrcrd = pr_nrctrcrd; Não deve mais utilizar o código do contrato
             AND crawcrd.nrseqcrd = pr_nrseqcrd; -- Código do contrato enviado ao Bancoob
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crawcrd: '||SQLERRM;
      END altera_sit_cartao_aprovado;
      
      PROCEDURE altera_data_rejeicao(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                     pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                     pr_nrseqcrd IN crawcrd.nrseqcrd%TYPE,
                                     pr_dtmvtolt IN crawcrd.dtmvtolt%TYPE)IS
        -- Atualiza a data de Rejeicao da proposta
        BEGIN
            UPDATE crawcrd
               SET dtrejeit = pr_dtmvtolt
             WHERE crawcrd.cdcooper = pr_cdcooper
               AND crawcrd.nrdconta = pr_nrdconta
               AND crawcrd.nrseqcrd = pr_nrseqcrd -- Código do contrato enviado ao Bancoob
               AND ((crawcrd.dtrejeit IS NULL) OR (pr_dtmvtolt IS NULL));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar crawcrd: '||SQLERRM;
            
      END altera_data_rejeicao;

      -- Atualiza o campo cdpesqbb do tipo 1 com as inforamções de tipo 2 
      PROCEDURE atualiza_nmtitcrd(pr_cdcooper IN craprej.cdcooper%TYPE,
                                  pr_cdagenci IN craprej.cdagenci%TYPE,
                                  pr_nrdconta IN craprej.nrdconta%TYPE,
                                  pr_dtmvtolt IN craprej.dtmvtolt%TYPE,
                                  pr_cdpesqbb IN craprej.cdpesqbb%TYPE)IS
        
        BEGIN
           UPDATE craprej rej
            SET rej.cdpesqbb = pr_cdpesqbb
           WHERE rej.cdcooper = pr_cdcooper
            AND rej.cdagenci = pr_cdagenci
            AND rej.nrdconta = pr_nrdconta
            AND rej.dtmvtolt = pr_dtmvtolt
            AND rej.cdpesqbb IS NULL;


        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar craprej: '||SQLERRM;

      END atualiza_nmtitcrd;
      
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_xml(pr_xml_clobxml IN OUT CLOB,
                               pr_des_dados   IN VARCHAR2) IS
        BEGIN
          -- ESCREVE DADOS NA VARIAVEL vr_clobxml QUE IRA CONTER OS DADOS DO XML
          dbms_lob.writeappend(pr_xml_clobxml, length(pr_des_dados), pr_des_dados);
        END;
      
      -- Atualiza os dados do cartao de credito
      PROCEDURE atualiza_dados_cartao(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                      pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                      pr_cdagenci IN crapass.cdagenci%TYPE,
                                      pr_nrdctitg IN crawcrd.nrcctitg%TYPE,
                                      pr_vllimcrd IN crawcrd.vllimcrd%TYPE,
                                      pr_dddebito IN crawcrd.dddebito%TYPE,
                                      pr_flgdebcc IN INTEGER,
                                      pr_tpdpagto IN INTEGER,
                                      pr_nmrescop IN crapcop.nmrescop%TYPE,
                                      pr_nmextage IN crapage.nmextage%TYPE,
                                      pr_nmprimtl IN crapass.nmprimtl%TYPE,
                                      pr_xml_lim_cartao IN OUT CLOB,
                                      pr_des_erro OUT VARCHAR2,
                                      pr_cdcritic OUT INTEGER,
                                      pr_dscritic OUT VARCHAR2) IS
                        
        -- Buscar todos os cartao da conta integracao
        CURSOR cr_crawcrd_limite(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                 pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                 pr_nrcctitg IN crawcrd.nrcctitg%TYPE) IS
          SELECT crawcrd.cdadmcrd,
                 crawcrd.vllimcrd,
                 crawcrd.nrcrcard,
                 row_number() over(partition by crawcrd.cdcooper, crawcrd.nrdconta, crawcrd.cdadmcrd
                                       order by crawcrd.cdcooper, crawcrd.nrdconta, crawcrd.cdadmcrd) nrseqreg,
                 progress_recid
            FROM crawcrd
           WHERE crawcrd.cdcooper = pr_cdcooper
             AND crawcrd.nrdconta = pr_nrdconta
             AND crawcrd.nrcctitg = pr_nrcctitg;
        
        -- Busca o Bandeira da Administradora
        CURSOR cr_crapadc(pr_cdcooper IN crapadc.cdcooper%TYPE,
                          pr_cdadmcrd IN crapadc.cdadmcrd%TYPE) IS
          SELECT nmbandei,
                 cdadmcrd,
                 nmresadm
            FROM crapadc
           WHERE crapadc.cdcooper = pr_cdcooper
             AND crapadc.cdadmcrd = pr_cdadmcrd;
        rw_crapadc cr_crapadc%ROWTYPE;
      
        --Variaveis de Excecao
        vr_exc_erro   EXCEPTION;
        vr_craptlc    BOOLEAN := FALSE;
        vr_cdlimcrd   crawcrd.cdlimcrd%TYPE; --> Codigo da linha do valor de credito
        vr_nrcrcard   VARCHAR2(19);
          
      BEGIN
        
        pr_des_erro := 'NOK';
        vr_cdlimcrd := 0;
        
        /* Vamos atualizar todos os cartoes de acordo com a conta integracao que veio no arquivo */
        FOR rw_crawcrd_limite IN cr_crawcrd_limite(pr_cdcooper => pr_cdcooper,
                                                   pr_nrdconta => pr_nrdconta,
                                                   pr_nrcctitg => pr_nrdctitg) LOOP
          
          -- Para cada Administradora vamos buscar o Limite de Credito
          IF rw_crawcrd_limite.nrseqreg = 1 THEN
            
            -- Vamos buscar a Bandeira da Administradora
            OPEN cr_crapadc(pr_cdcooper => pr_cdcooper,
                            pr_cdadmcrd => rw_crawcrd_limite.cdadmcrd);
            FETCH cr_crapadc INTO rw_crapadc;
            IF cr_crapadc%NOTFOUND THEN
              CLOSE cr_crapadc;
              pr_dscritic := 'Administradora nao encontrada. Codigo: ' || TO_CHAR(rw_crawcrd_limite.cdadmcrd);
              RAISE vr_exc_erro;              
              
            ELSE
              CLOSE cr_crapadc;
            END IF;          
            
            -- Somente a administadora diferente de MAESTRO que ira ter Limite cadastrado
            IF UPPER(rw_crapadc.nmbandei) <> 'MAESTRO' THEN
              -- Para cada cartao, vamos buscar o valor de limite de credito cadastrado
              OPEN cr_craptlc(pr_cdcooper => pr_cdcooper,
                              pr_cdadmcrd => rw_crawcrd_limite.cdadmcrd,
                              pr_vllimcrd => pr_vllimcrd);
              FETCH cr_craptlc INTO rw_craptlc;
              vr_craptlc := cr_craptlc%FOUND;
              CLOSE cr_craptlc;
              
              vr_cdlimcrd := rw_craptlc.cdlimcrd;
            ELSE
              vr_craptlc := TRUE;  
            END IF;  
            
          END IF; /* END IF rw_crawcrd_limite.nrseqreg = 1 THEN */
          
          -- Vamos verificar se o Limite existe
          IF NOT vr_craptlc THEN
            vr_nrcrcard := TO_CHAR(rw_crawcrd_limite.nrcrcard);
            vr_nrcrcard := fn_mask_cartao(vr_nrcrcard);
            
            -- Caso nao achou o Limite de Credito, vamos armazenar no XML para a geracao do relatorio
            pc_escreve_xml(pr_xml_lim_cartao,'<Dados>'||
                                                 '<cdcooper>'||pr_cdcooper||'</cdcooper>'||
                                                 '<nmrescop>'||pr_nmrescop||'</nmrescop>'||
                                                 '<cdagenci>'||pr_cdagenci||'</cdagenci>'||
                                                 '<nmextage>'||pr_nmextage||'</nmextage>'||
                                                 '<nrdconta>'||LTrim(gene0002.fn_mask_conta(pr_nrdconta))||'</nrdconta>'||
                                                 '<nrcrcard>'|| vr_nrcrcard ||'</nrcrcard>'||                                                 
                                                 '<nmprimtl>'||pr_nmprimtl||'</nmprimtl>'||
                                                 '<cdadmcrd>'||rw_crapadc.cdadmcrd||'</cdadmcrd>'||
                                                 '<nmresadm>'||rw_crapadc.nmresadm||'</nmresadm>'||
                                                 '<limite_bancoob>'||to_char(pr_vllimcrd,'fm999g999g990d00')||'</limite_bancoob>'||
                                                 '<limite_ayllos>'||to_char(rw_crawcrd_limite.vllimcrd,'fm999g999g990d00')||'</limite_ayllos>'||
                                             '</Dados>');
          ELSE
            -- Atualiza os dados do cartao de credito
            BEGIN
              UPDATE crawcrd SET 
                     dddebant = crawcrd.dddebito,
                     dddebito = pr_dddebito,
                     flgdebcc = pr_flgdebcc,
                     tpdpagto = pr_tpdpagto,
                     vllimcrd = pr_vllimcrd,
                     cdlimcrd = vr_cdlimcrd
               WHERE crawcrd.progress_recid = rw_crawcrd_limite.progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar crawcrd: ' || SQLERRM;
                RAISE vr_exc_erro;
            END;    
                  
          END IF;                    
                      
        END LOOP; /* END FOR rw_crawcrd_limite */
        
        pr_des_erro := 'OK';
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'NOK';
        WHEN OTHERS THEN
          pr_des_erro := 'NOK';
          --Variavel de erro recebe erro ocorrido
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar os dados do cartao. Rotina PC_CRPS672.atualiza_dados_cartao. '||sqlerrm;

      END atualiza_dados_cartao;
      
      -- Atualiza a situacao do cartao de credito
      PROCEDURE atualiza_situacao_cartao(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                                         pr_nrdconta IN crawcrd.nrdconta%TYPE,
                                         pr_nrcrcard IN crawcrd.nrcrcard%TYPE,
                                         pr_insitcrd IN crawcrd.insitcrd%TYPE,
                                         pr_dtmvtolt IN DATE,
                                         pr_des_erro OUT VARCHAR2,
                                         pr_cdcritic OUT INTEGER,
                                         pr_dscritic OUT VARCHAR2) IS
                
        -- Tabela de Limite de Credito
        CURSOR cr_tbcrd_situacao(pr_cdsitadm tbcrd_situacao.cdsitadm%TYPE) IS
          SELECT cdsitcrd,
                 cdmotivo
            FROM tbcrd_situacao
           WHERE tbcrd_situacao.cdsitadm = pr_cdsitadm;
        rw_tbcrd_situacao cr_tbcrd_situacao%ROWTYPE;
             
        -- Buscar os dados do cartao de credito
        CURSOR cr_crawcrd(pr_cdcooper IN crawcrd.cdcooper%TYPE,
                          pr_nrdconta IN crawcrd.nrdconta%TYPE,
                          pr_nrcrcard IN crawcrd.nrcrcard%TYPE) IS                          
          SELECT crawcrd.insitcrd,
                 crawcrd.dtcancel,
                 crawcrd.cdmotivo
            FROM crawcrd
           WHERE crawcrd.cdcooper = pr_cdcooper
             AND crawcrd.nrdconta = pr_nrdconta
             AND crawcrd.nrcrcard = pr_nrcrcard;
        rw_crawcrd cr_crawcrd%ROWTYPE;
             
        vr_insitcrd crawcrd.insitcrd%TYPE;
        vr_dtcancel crawcrd.dtcancel%TYPE;
        vr_cdmotivo crawcrd.cdmotivo%TYPE;
        vr_nrdrowid ROWID;
        --Variaveis de Excecao
        vr_exc_erro EXCEPTION;
             
      BEGIN
        
        pr_des_erro := 'NOK';
        
        -- Vamos buscar os dados do cartao
        OPEN cr_crawcrd(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_nrcrcard => pr_nrcrcard);
        FETCH cr_crawcrd
         INTO rw_crawcrd;
        -- Verifica se existe a situacao cadastrada
        IF cr_crawcrd%NOTFOUND THEN
          CLOSE cr_crawcrd;          
          pr_dscritic := 'Cartao nao encontrado. Conta: ' || TO_CHAR(pr_nrdconta) || '. Cartao: ' || fn_mask_cartao(TO_CHAR(pr_nrcrcard));
          RAISE vr_exc_erro;
        END IF;
        CLOSE cr_crawcrd;
        
        -- Vamos buscar a situacao do cartao
        OPEN cr_tbcrd_situacao(pr_cdsitadm => pr_insitcrd);
        FETCH cr_tbcrd_situacao 
         INTO rw_tbcrd_situacao;
        -- Verifica se existe a situacao cadastrada
        IF cr_tbcrd_situacao%NOTFOUND THEN
          CLOSE cr_tbcrd_situacao;          
          pr_dscritic := 'Situacao nao encontrada. Conta: ' || TO_CHAR(pr_nrdconta) || '. Situacao: ' || TO_CHAR(pr_insitcrd);
          RAISE vr_exc_erro;            
        END IF;    
        CLOSE cr_tbcrd_situacao;
        
        /* Cancelado */
        IF rw_tbcrd_situacao.cdsitcrd = 6 THEN
          
          BEGIN
            UPDATE crawcrd SET
                   insitcrd = rw_tbcrd_situacao.cdsitcrd,
                   dtcancel = pr_dtmvtolt,
                   cdmotivo = rw_tbcrd_situacao.cdmotivo
             WHERE crawcrd.cdcooper = pr_cdcooper
               AND crawcrd.nrdconta = pr_nrdconta
               AND crawcrd.nrcrcard = pr_nrcrcard
            RETURNING insitcrd,
                      dtcancel,
                      cdmotivo
                 INTO vr_insitcrd,
                      vr_dtcancel,
                      vr_cdmotivo;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar crawcrd: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
          
        ELSE
          
          BEGIN
            UPDATE crawcrd SET
                   insitcrd = rw_tbcrd_situacao.cdsitcrd,
                   dtcancel = NULL,
                   cdmotivo = 0
             WHERE crawcrd.cdcooper = pr_cdcooper
               AND crawcrd.nrdconta = pr_nrdconta
               AND crawcrd.nrcrcard = pr_nrcrcard
            RETURNING insitcrd,
                      dtcancel,
                      cdmotivo
                 INTO vr_insitcrd,
                      vr_dtcancel,
                      vr_cdmotivo;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar crawcrd: ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        
        END IF;
        
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
				                     pr_cdoperad => '1',
													   pr_dscritic => '',
													   pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(1)),
													   pr_dstransa => 'Alterar Situacao Cartao de Credito',
													   pr_dttransa => TRUNC(SYSDATE),
													   pr_flgtrans => 1,
													   pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
													   pr_idseqttl => 0,
													   pr_nmdatela => 'PC_CRPS672',
													   pr_nrdconta => pr_nrdconta,
													   pr_nrdrowid => vr_nrdrowid);

        -- Numero do Cartao
			  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
				  												pr_nmdcampo => 'Cartao',
					  											pr_dsdadant => '',
						  										pr_dsdadatu => pr_nrcrcard);
                                  
        -- Situacao do Cartao
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
				  												pr_nmdcampo => 'Situacao',
					  											pr_dsdadant => rw_crawcrd.insitcrd,
						  										pr_dsdadatu => vr_insitcrd);
        
        -- Data de Cancelamento
        IF rw_crawcrd.dtcancel <> vr_dtcancel THEN
           gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'Data Canc.',
                                     pr_dsdadant => rw_crawcrd.dtcancel,
                                     pr_dsdadatu => vr_dtcancel);
        END IF;
        
        -- Motivo
        IF rw_crawcrd.cdmotivo <> vr_cdmotivo THEN
           gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                     pr_nmdcampo => 'Motivo',
                                     pr_dsdadant => rw_crawcrd.cdmotivo,
                                     pr_dsdadatu => vr_cdmotivo);
        END IF;
                                
        pr_des_erro := 'OK';
        
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_des_erro := 'NOK';
        WHEN OTHERS THEN
          pr_des_erro := 'NOK';
          --Variavel de erro recebe erro ocorrido
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao atualizar a situacao do cartao. Rotina PC_CRPS672.atualiza_situacao_cartao. '||sqlerrm;

      END atualiza_situacao_cartao;      

      -- Subrotina para escrever críticas no LOG do processo
      PROCEDURE pc_log_message IS
        BEGIN
          -- Se foi retornado apenas código
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descrição
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')|| ' - '
                                                                        || vr_cdprogra || ' --> '
                                                                        || vr_dscritic );
            vr_cdcritic := 0;
            vr_dscritic := '';
          END IF;
        END pc_log_message;

    BEGIN
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
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
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

      -- Validacoes iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel nao for 0
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- buscar informações do arquivo a ser processado
      OPEN cr_crapscb;
      FETCH cr_crapscb INTO rw_crapscb;
      CLOSE cr_crapscb;

      -- buscar caminho de arquivos do Bancoob/CABAL
      vr_direto_connect := rw_crapscb.dsdirarq || '/recebe';

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null);


      -- monta nome do arquivo
      vr_nmrquivo := 'CCR3756' || TO_CHAR(lpad(rw_crapcop.cdagebcb,4,'0')) || '_*.*';

      -- Apaga o arquivo pc_crps672.txt caso exista
      vr_comando:= 'rm ' || vr_direto_connect || '/pc_crps672.txt 2> /dev/null';
      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);

      --Verificar se existe arquivo(s) para ser processado
      vr_comando:= 'ls ' || vr_direto_connect || '/'|| vr_nmrquivo || ' | wc -l ';
      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_saida;
      ELSE
        --Se retornou zero arquivos entao sai do programa
        IF substr(vr_dscritic,1,1) = '0' OR vr_dscritic IS NULL THEN
          --Montar mensagem critica
          vr_cdcritic:= 182;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          --Levantar Excecao
          RAISE vr_exc_fimprg;
        END IF;
      END IF;

      -- Criar o arquivo pc_crps672.txt baseado no comando LS
      vr_comando:= 'ls ' || vr_direto_connect || '/'|| vr_nmrquivo|| ' 1>> '|| vr_direto_connect || '/pc_crps672.txt';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;

      --Bloco de leitura do arquivo pc_crps672.txt

      BEGIN
         /*Popula o vetor com as informações do tipo de solicitação*/
          vr_vet_nmtipsol(0) := 'ERR - TIPO DE SOLICITAÇAO EM BRANCO';
          vr_vet_nmtipsol(1) := 'INCLUSAO DE CARTAO';
          vr_vet_nmtipsol(2) := 'MODIFICACAO DE CONTA CARTAO';
          vr_vet_nmtipsol(3) := 'CANCELAMENTO DE CARTAO';
          vr_vet_nmtipsol(4) := 'INCLUSAO DE CARTAO ADICIONAL/REPOSICAO DE CARTAO';
          vr_vet_nmtipsol(5) := 'MODIFICACAO DE CARTAO';
          vr_vet_nmtipsol(6) := 'MODIFICACAO DE DOCUMENTO';
          vr_vet_nmtipsol(7) := 'REATIVACAO DE CARTAO';
          vr_vet_nmtipsol(8) := 'REIMPRESSAO DE PIN';
          vr_vet_nmtipsol(9) := 'BAIXA DE PARCELADOS';
          vr_vet_nmtipsol(10) := 'DESBLOQUEIO DE CARTAO';
          vr_vet_nmtipsol(11) := 'ENTREGA DE CARTAO';
          vr_vet_nmtipsol(12) := 'TROCA DE ESTADO DE CARTAO';
          vr_vet_nmtipsol(13) := 'ALTERACAO DE CONTA CARTAO';
          vr_vet_nmtipsol(14) := 'CAD. DEB. AUTOMATICO';
          vr_vet_nmtipsol(16) := 'BAIXA DE PARCELAS';
          vr_vet_nmtipsol(25) := 'REATIVAR CARTAO DO ADICIONAL';
          vr_vet_nmtipsol(50) := 'MODIFICACAO DE PIN';
          vr_vet_nmtipsol(99) := 'EXCLUSAO DE CARTAO';
          
        --Abre o arquivo pc_crps672.txt
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_direto_connect --> Diretório do arquivo
                                 ,pr_nmarquiv => 'pc_crps672.txt'  --> Nome do arquivo
                                ,pr_tipabert => 'R'               --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_ind_arquiv     --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);     --> Erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

        LOOP
          -- Verifica se o arquivo está aberto
          IF  utl_file.IS_OPEN(vr_ind_arquiv) THEN
            -- Le os dados em pedaços e escreve no Blob
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                        ,pr_des_text => vr_nmarquiv); --> Texto lido
            -- Incrementar contador
            vr_contador:= Nvl(vr_contador,0) + 1;

            -- Separar o nome do arquivo do caminho
            GENE0001.pc_separa_arquivo_path(pr_caminho => vr_nmarquiv
                                           ,pr_direto  => vr_direto_connect
                                           ,pr_arquivo => vr_nmarquiv);
            -- Popular o vetor de arquivos
            vr_vet_nmarquiv(vr_contador):= vr_nmarquiv;

          END IF;
        END LOOP;

        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;

        -- Apaga o arquivo pc_crps672.txt no unix
         vr_comando:= 'rm ' || vr_direto_connect || '/pc_crps672.txt 2> /dev/null';
        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        IF vr_typ_saida = 'ERR' THEN
          RAISE vr_exc_saida;
        END IF;

      EXCEPTION
        WHEN utl_file.invalid_operation THEN
          -- Nao conseguiu abrir o arquivo
          vr_dscritic:= 'Erro ao abrir o arquivo pc_crps672.txt na rotina pc_crps672.';
          RAISE vr_exc_saida;
        WHEN no_data_found THEN
          -- Terminou de ler o arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;
      END;

      -- Se o contador está zerado
      IF vr_contador = 0 THEN
        vr_cdcritic:= 182;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_fimprg;
      END IF;

      -- Guardar a maior sequencia processada
      vr_nrseqarq_max := rw_crapscb.nrseqarq;
      
      dbms_lob.createtemporary(vr_xml_lim_cartao, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_lim_cartao, dbms_lob.lob_readwrite);
      pc_escreve_xml(vr_xml_lim_cartao, '<?xml version="1.0" encoding="utf-8"?><crrl707>');

      -- Percorre cada arquivo encontrado
      FOR i IN 1..vr_contador LOOP

        -- adquire sequencial do arquivo
        vr_nrseqarq  := to_number(substr(vr_vet_nmarquiv(i),13,7));

        -- Verificar se sequencial já foi importado
        IF nvl(rw_crapscb.nrseqarq,0) >= nvl(vr_nrseqarq,0) THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Sequencial do arquivo '|| vr_vet_nmarquiv(i) ||
                         ' deve ser maior que o ultimo já processado (seq arq.: ' ||vr_nrseqarq||
                         ', Ult. seq.: ' || rw_crapscb.nrseqarq|| '), arquivo não será processado.';
          -- gravar log do erro
          pc_log_message;
          CONTINUE;
        -- verificar se não pulou algum sequencial
        ELSIF nvl(vr_nrseqarq_max,0) + 1 <> nvl(vr_nrseqarq,0) THEN
          -- Montar mensagem de critica
          vr_dscritic := 'Falta sequencial de arquivo ' ||
                         '(seq arq.: ' ||vr_nrseqarq|| ', Ult. seq.: ' || vr_nrseqarq_max||
                         '), arquivo '|| vr_vet_nmarquiv(i) ||' não será processado.';
          -- gravar log do erro
          pc_log_message;
          CONTINUE;
        END IF;

        -- Guardar a maior sequencia processada
        vr_nrseqarq_max := greatest(vr_nrseqarq_max,vr_nrseqarq);

        gene0001.pc_abre_arquivo(pr_nmdireto => vr_direto_connect  --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_vet_nmarquiv(i) --> Nome do arquivo
                                ,pr_tipabert => 'R'                --> modo de abertura (r,w,a)
                                ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);      --> erro
        -- em caso de crítica
        IF vr_dscritic IS NOT NULL THEN
          -- levantar excecao
          RAISE vr_exc_saida;
        END IF;

        -- Se o arquivo estiver aberto, percorre o mesmo e guarda todas as linhas
        IF  utl_file.IS_OPEN(vr_ind_arquiv) THEN
          -- Ler todas as linhas do arquivo
          LOOP
            BEGIN
              -- Lê a linha do arquivo aberto
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                          ,pr_des_text => vr_des_text); --> Texto lido
              -- se for HEADER
              IF substr(vr_des_text,5,2) = '00'  THEN
                CONTINUE;
              END IF;

              -- se for DADOS CONTA CARTÃO
              IF substr(vr_des_text,5,2) = '01'  THEN

                vr_tipooper := to_number(substr(vr_des_text,7,2));
                
                 /*
                1 - Inclusao de Cartao
                2 - Modificacao de Conta Cartao
                3 - Cancelamento de Cartao
                4 - Inclusao de Adicional
                7 - Reativacao de Contas
                12 - Alteracao de Estado
                13 - Alteracao de Estado Conta
                */                
               
                IF vr_tipooper NOT IN (1,2,3,4,7,12,13) THEN
                   CONTINUE;
                END IF;
                
                -- Guardar contas do arquivo para verificação
                vr_nrctatp1 := to_number(TRIM(substr(vr_des_text,221,8)));
                vr_nrctatp2 := 0;
                
                -- Se o numero da conta chegou com zero
                -- Pegar o campo "Numero da Conta a Debitar"
                IF NVL(vr_nrctatp1,0) = 0 THEN
                  vr_nrctatp1 := to_number(TRIM(substr(vr_des_text,206,12)));
                END IF;
                
                -- Buscar valores
                vr_tipooper := to_number(substr(vr_des_text,7,2));
                vr_nroperac := to_number(substr(vr_des_text,9,8));
                vr_cdgrafin := to_number(substr(vr_des_text,42,7));
                vr_nrdconta := vr_nrctatp1;
                vr_nrcanven := to_char(substr(vr_des_text,286,8));
                vr_dddebito := to_number(substr(vr_des_text,243,2));
                vr_vllimcrd := substr(vr_des_text,250,9);
                vr_tpdpagto := TO_NUMBER(substr(vr_des_text,218,3));
                vr_flgdebcc := TO_NUMBER(substr(vr_des_text,198,1));
                vr_cdagebcb := to_number(substr(vr_des_text,202,4));
                vr_nrdctitg := to_number( substr(vr_des_text,25,13));
                
                -- Se vier agencia bancoob zerada, obtem do Nr. da Conta Cartão
                IF vr_cdagebcb = 0 THEN
                  vr_cdagebcb := to_number(substr(vr_des_text,28,4));
                END IF;
                
                -- Debito em Conta Corrente
                IF vr_flgdebcc = 1 OR vr_flgdebcc = 2 THEN
                  vr_flgdebcc := 1;
                ELSE
                  vr_flgdebcc := 0;                
                END IF;
                
                -- Tipo de Pagamento
                IF vr_tpdpagto = 0 THEN
                  vr_tpdpagto := 3;
                END IF;
        
                -- busca a cooperativa com base no cod. da agencia central do arquivo
                OPEN cr_crapcop_cdagebcb(pr_cdagebcb => vr_cdagebcb);
                FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;

                IF cr_crapcop_cdagebcb%NOTFOUND THEN
                  -- Fechar o cursor pois havera raise
                  CLOSE cr_crapcop_cdagebcb;
                  -- Montar mensagem de critica
                  vr_dscritic := 'Codigo da agencia do Bancoob ' || to_char(vr_cdagebcb) ||
                                 ' nao possui Cooperativa correspondente.';
                  
                  -- gravar log do erro
                  pc_log_message;
                  -- Próxima linha
                  CONTINUE;
                END IF;

                -- Fecha cursor cooperativa
                CLOSE cr_crapcop_cdagebcb;

                -- faz associação da variavel cod cooperativa;
                vr_cdcooper := rw_crapcop_cdagebcb.cdcooper;
                
                -- Busca dados da agencia cooperado
                OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta);
                FETCH cr_crapass INTO rw_crapass;
                CLOSE cr_crapass;

                -- Verifica se houve rejeição do Tipo de Registro 1
                IF substr(vr_des_text,275,3) <> '000' THEN
                  
                  -- Somente os registros d Inclusao sera gravado na tabela craprej
                  IF substr(vr_des_text,7,2) = '01' THEN
                  
                     BEGIN
                        INSERT INTO craprej
                          (cdcooper,
                           cdagenci,
                           cdpesqbb,
                           dshistor,
                           dtmvtolt,
                           cdcritic,
                           dtrefere,
                           nrdconta,
                           nrdctitg,
                           nrdocmto)
                        VALUES
                          (vr_cdcooper,
                           rw_crapass.cdagenci,
                           '',
                           'CCR3',
                           rw_crapdat.dtmvtolt,
                           TO_NUMBER(substr(vr_des_text,275,3)),
                           TO_DATE(substr(vr_des_text,17,8),'DDMMYYYY'),
                           vr_nrdconta,
                           vr_nrdctitg,
                           TO_NUMBER(substr(vr_des_text,9,8)));
                     EXCEPTION
                       WHEN OTHERS THEN
                         vr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
                         RAISE vr_exc_saida;
                     END;

                     -- Altera a situação da Proposta de Cartão para 1 (Aprovado)
                     altera_sit_cartao_aprovado(pr_cdcooper => vr_cdcooper,
                                                pr_nrdconta => vr_nrdconta,
                                                pr_nrseqcrd => vr_nroperac);
                                                 
                     -- Limpa a data de rejeicao da proposta do cartao
                     altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                          pr_nrdconta => vr_nrdconta,
                                          pr_nrseqcrd => vr_nroperac,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt);
                  END IF;
                                                 
                  CONTINUE;
                  
                ELSE
                  -- Limpa a data de rejeicao da proposta do cartao
                  altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                       pr_nrdconta => vr_nrdconta,
                                       pr_nrseqcrd => vr_nroperac,
                                       pr_dtmvtolt => NULL);
                                       
                  -- Atualiza os dados do cartao de credito
                  atualiza_dados_cartao(pr_cdcooper       => vr_cdcooper,
                                        pr_nrdconta       => vr_nrdconta,
                                        pr_cdagenci       => rw_crapass.cdagenci,
                                        pr_nrdctitg       => vr_nrdctitg,
                                        pr_vllimcrd       => vr_vllimcrd,
                                        pr_dddebito       => vr_dddebito,
                                        pr_flgdebcc       => vr_flgdebcc,
                                        pr_tpdpagto       => vr_tpdpagto,
                                        pr_nmrescop       => rw_crapcop_cdagebcb.nmrescop,
                                        pr_nmextage       => rw_crapass.nmextage,
                                        pr_nmprimtl       => rw_crapass.nmprimtl,
                                        pr_xml_lim_cartao => vr_xml_lim_cartao,
                                        pr_des_erro       => vr_des_erro,
                                        pr_cdcritic       => vr_cdcritic,
                                        pr_dscritic       => vr_dscritic);
                                      
                  IF vr_des_erro <> 'OK' THEN
                    pc_log_message;
                    vr_des_erro := '';
                  
                  END IF;
                  
                END IF; /* END IF substr(vr_des_text,275,3) <> '000'  THEN */
                
              END IF;

              -- se for DADOS DO CARTÃO
              IF substr(vr_des_text,5,2) = '02'  THEN

                -- Guardar contas do arquivo para verificação
                vr_nrctatp2 := to_number(TRIM(substr(vr_des_text,337,12)));
                vr_tipooper := to_number(substr(vr_des_text,7,2));
                vr_cdlimcrd := 0;
                -- Agencia do banco
                vr_cdagebcb := to_number(substr(vr_des_text,333,4));
                -- Se vier agencia bancoob zerada, obtem do Nr. da Conta Cartão
                IF vr_cdagebcb = 0 THEN
                  vr_cdagebcb := to_number(substr(vr_des_text,28,4));
                END IF;                
                
                /*
                1 - Inclusao de Cartao
                3 - Cancelamento de Cartao
                4 - Inclusao de Adicional
                7 - Reativacao de Contas
                10 - Desbloqueio (exclusivo p/ tratamento de reposicao)
                12 - Alteracao de Estado
                13 - Alteracao de Estado Conta
                25 - Reativar Cartao do Adicional                
                */                
                IF vr_tipooper NOT IN (1,3,4,7,10,12,13,25) THEN
                   CONTINUE;
                END IF;
                
                -- busca a cooperativa com base no cod. da agencia central do arquivo
                OPEN cr_crapcop_cdagebcb(pr_cdagebcb => vr_cdagebcb);
                FETCH cr_crapcop_cdagebcb INTO rw_crapcop_cdagebcb;
                IF cr_crapcop_cdagebcb%NOTFOUND THEN
                  -- Fechar o cursor pois havera raise
                  CLOSE cr_crapcop_cdagebcb;
                  -- Montar mensagem de critica
                  vr_dscritic := 'Codigo da agencia do Bancoob ' || to_char(vr_cdagebcb) ||
                                 ' nao possui Cooperativa correspondente.';
                  
                  -- gravar log do erro
                  pc_log_message;
                  -- Próxima linha
                  CONTINUE;
                ELSE
                  -- Fecha cursor cooperativa
                  CLOSE cr_crapcop_cdagebcb;
                END IF;                

                -- faz associação da variavel cod cooperativa;
                vr_cdcooper := rw_crapcop_cdagebcb.cdcooper;                
                
                -- Caso o numero da conta for igual a 0, vamos buscar o numero da conta pelo CPF
                IF NVL(vr_nrctatp2,0) = 0 THEN
                  
                  OPEN cr_crawcrd_outros_nrcctitg(pr_cdcooper => vr_cdcooper,
                                                  pr_nrcctitg => TO_NUMBER(substr(vr_des_text,25,13)));                                         
                  FETCH cr_crawcrd_outros_nrcctitg INTO rw_crawcrd_outros_nrcctitg;

                  IF cr_crawcrd_outros_nrcctitg%FOUND THEN
                    CLOSE cr_crawcrd_outros_nrcctitg;                    
                    vr_nrctatp2 := rw_crawcrd_outros_nrcctitg.nrdconta;
                  ELSE
                    CLOSE cr_crawcrd_outros_nrcctitg;                    
                  OPEN cr_crawcrd_outros(pr_cdcooper => vr_cdcooper,
                                           pr_nrseqcrd => TO_NUMBER(substr(vr_des_text,9,8)));                                         
                  FETCH cr_crawcrd_outros INTO rw_crawcrd_outros;
                  IF cr_crawcrd_outros%NOTFOUND THEN
                    -- Fechar o cursor pois havera raise
                    CLOSE cr_crawcrd_outros;                    
                    CONTINUE;
                  ELSE
                    CLOSE cr_crawcrd_outros;                    
                  END IF;
                  vr_nrctatp2 := rw_crawcrd_outros.nrdconta;
                  END IF;
                END IF;                
                
                -- Se não veio conta
                IF NVL(vr_nrctatp2,0) = 0 THEN                  
                  -- Ignora a linha
                  CONTINUE; 
                END IF;
                
                vr_nrdconta := vr_nrctatp2;
                
                IF vr_tipooper IN (1,4) THEN
                  -- Buscar informação do cartão verificando se o mesmo está encerrado (cancelado)
                  OPEN  cr_crawcrd_encerra(vr_cdcooper                            --pr_cdcooper
                                          ,vr_nrdconta                            --pr_nrdconta
                                          ,TO_NUMBER(substr(vr_des_text,25,13))   --pr_nrcctitg
                                          ,TO_NUMBER(substr(vr_des_text,38,19))); --pr_nrcrcard
                  FETCH cr_crawcrd_encerra INTO rw_crawcrd_encerra;
                  -- Se encontrar o cartão como encerrado (cancelado)
                  IF cr_crawcrd_encerra%FOUND THEN
                    -- fecha o cursor
                    CLOSE cr_crawcrd_encerra;
                    CONTINUE; -- Ignora o registro
                  END IF;                
                  CLOSE cr_crawcrd_encerra;
                  
                END IF;
                
                -- Busca dados da agencia cooperado
                OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta);
                FETCH cr_crapass INTO rw_crapass;
                CLOSE cr_crapass;
                
                -- Se for dados do cartão, e os dados forem de um CNPJ (pos93 = 3)
                IF TO_NUMBER(substr(vr_des_text,93,02)) = '03' THEN                  
                  /* nao deve solicitar cartao novamente caso retorne critica 080
                     (pessoa ja tem cartao nesta conta) */
                  IF substr(vr_des_text, 211, 3) = '080' THEN
                    continue;
                  END IF;
                  
                  vr_nmtitcrd := substr(vr_des_text,38,19)||substr(vr_des_text,250,23)||substr(vr_des_text,7,2);
                  
                  -- Verifica se houve rejeição do Tipo de Registro 2
                  IF substr(vr_des_text,211,3) <> '000'  THEN                    
                    BEGIN
                      INSERT INTO craprej
                         (cdcooper,
                          cdagenci,
                          cdpesqbb,
                          dshistor,
                          dtmvtolt,
                          cdcritic,
                          dtrefere,
                          nrdconta,
                          nrdctitg,
                          nrdocmto)
                      VALUES
                          (vr_cdcooper,
                           rw_crapass.cdagenci,
                           vr_nmtitcrd,
                           'CCR3',
                           rw_crapdat.dtmvtolt,
                           TO_NUMBER(substr(vr_des_text,211,3)),
                           TO_DATE(substr(vr_des_text,17,8),'DDMMYYYY'),
                           vr_nrdconta,
                           vr_nrdctitg,
                           TO_NUMBER(substr(vr_des_text,9,8)));
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
                        RAISE vr_exc_saida;
                      END;

                    -- Atualiza o campo cdpesqbb do tipo 1 com as inforamções de tipo 2 
                    atualiza_nmtitcrd(vr_cdcooper,
                                      rw_crapass.cdagenci,
                                      vr_nrdconta,
                                      rw_crapdat.dtmvtolt,
                                      vr_nmtitcrd); 
                        
                    -- Altera a situação da Proposta de Cartão para 1 (Aprovado)
                    altera_sit_cartao_aprovado(pr_cdcooper => vr_cdcooper,
                                               pr_nrdconta => vr_nrdconta,
                                               pr_nrseqcrd => vr_nroperac);
                                                  
                    altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                         pr_nrdconta => vr_nrdconta,
                                         pr_nrseqcrd => vr_nroperac,
                                         pr_dtmvtolt => rw_crapdat.dtmvtolt);
                    
                    CONTINUE;
                  ELSE
                    -- Atualiza o campo cdpesqbb do tipo 1 com as inforamções de tipo 2 
                    atualiza_nmtitcrd(vr_cdcooper,
                                      rw_crapass.cdagenci,
                                      vr_nrdconta,
                                      rw_crapdat.dtmvtolt,
                                      vr_nmtitcrd);
                                         
                    CONTINUE;                      
                  END IF;
                END IF;
                
                /* Tratamento especifico para casos de operacao 10 (desbloqueio), porem, onde a
                   informacao que vem no arquivo informa que o cartao esta sendo REPOSTO (deve cancelar).
                   Fabricio - chamado 559710 */
                IF vr_tipooper = 10 THEN
                  IF TO_NUMBER(substr(vr_des_text,114,2)) = 10 THEN /*reposicao*/
                    -- Atualiza os dados da situacao do cartao
                    atualiza_situacao_cartao(pr_cdcooper => vr_cdcooper,
                                             pr_nrdconta => vr_nrdconta,
                                             pr_nrcrcard => TO_NUMBER(substr(vr_des_text,38,19)),                                           
                                             pr_insitcrd => TO_NUMBER(substr(vr_des_text,114,2)),                                    
                                             pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                             pr_des_erro => vr_des_erro,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic);
                                             
                    -- Verifica se ocorreu erro                          
                    IF vr_des_erro <> 'OK' THEN
                      pc_log_message;
                      vr_des_erro := '';
                    END IF;
                  END IF;

                  -- tipo de operacao 10 (desbloqueio) nao deve fazer mais nada alem disto (Fabricio).
                  CONTINUE;
                END IF;
                
                /* 
                3 - Cancelamento de Cartao
                7 - Reativacao de Contas
                12 - Alteracao de Estado
                13 - Alteracao de Estado Conta
                25 - Reativar Cartao do Adicional                
                */                
                IF vr_tipooper IN (3,7,12,13,25) THEN
                  -- Atualiza os dados da situacao do cartao
                  atualiza_situacao_cartao(pr_cdcooper => vr_cdcooper,
                                           pr_nrdconta => vr_nrdconta,
                                           pr_nrcrcard => TO_NUMBER(substr(vr_des_text,38,19)),                                           
                                           pr_insitcrd => TO_NUMBER(substr(vr_des_text,114,2)),                                    
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                           pr_des_erro => vr_des_erro,
                                           pr_cdcritic => vr_cdcritic,
                                           pr_dscritic => vr_dscritic);
                                           
                  -- Verifica se ocorreu erro                          
                  IF vr_des_erro <> 'OK' THEN
                    pc_log_message;
                    vr_des_erro := '';
                  END IF;

                  CONTINUE;
                END IF;                
                
                -- Buscar as informações de operação e conta
                vr_nroperac := to_number(substr(vr_des_text,9,8));                
                -- Verifica se a operação é de inclusão de adicional, ou seja,
                -- verifica se a linha anterior processada refere-se a linha atual
                IF NVL(vr_nrctatp1,0) <> NVL(vr_nrctatp2,0) THEN
                  
                  -- Limpar as variáveis para evitar valores da iteração anterior
                  rw_crapacb.cdadmcrd := 0;
                  vr_cdgrafin := 0;
                  vr_dddebito := 0;
                  vr_vllimcrd := 0;
                  vr_tpdpagto := 0;
                  vr_flgdebcc := 0;
                  
                  -- Busca dados da agencia cooperado
                  OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                                  pr_nrdconta => vr_nrdconta);
                  FETCH cr_crapass INTO rw_crapass;
                  CLOSE cr_crapass;
                  
                  -- Buscar o contrato que esteja em uso
                  OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                 -- pr_cdcooper
                                           ,vr_nrdconta                 -- pr_nrdconta
                                           ,substr(vr_des_text,25,13)   -- pr_nrcctitg
                                           ,TO_NUMBER(substr(vr_des_text,95,15)) -- pr_nrcpftit
                                           ,NULL                        -- pr_insitcrd -- EM USO
                                           ,1 );                        -- pr_flgprcrd
                  FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                               , vr_dddebito
                                               , vr_vllimcrd
                                               , vr_tpdpagto
                                               , vr_flgdebcc;
                  -- Se não encontrar registros
                  IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                    -- Fechar o cursor
                    CLOSE cr_crawcrd_cdgrafin;                    
                    
                    -- Buscar registro de solicitacao
                    OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                 -- pr_cdcooper
                                             ,vr_nrdconta                 -- pr_nrdconta
                                             ,NULL                        -- pr_nrcctitg
                                             ,TO_NUMBER(substr(vr_des_text,95,15)) -- pr_nrcpftit
                                             ,2                             -- pr_insitcrd -- SOLICITADO
                                             ,NULL);                        -- pr_flgprcrd
                    FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                 , vr_dddebito
                                                 , vr_vllimcrd
                                                 , vr_tpdpagto
                                                 , vr_flgdebcc;
                    -- Se não encontrar registros
                    IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                      -- Fechar o cursor
                      CLOSE cr_crawcrd_cdgrafin;                                     
                    
                      -- Buscar pelo CPF do titular
                      OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                          -- pr_cdcooper
                                               ,vr_nrdconta                          -- pr_nrdconta
                                               ,NULL                                 -- pr_nrcctitg
                                               ,TO_NUMBER(substr(vr_des_text,95,15)) -- pr_nrcpftit
                                               ,3                                    -- pr_insitcrd -- LIBERADO
                                               ,NULL );                              -- pr_flgprcrd
                      FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                   , vr_dddebito
                                                   , vr_vllimcrd
                                                   , vr_tpdpagto
                                                   , vr_flgdebcc;  
                    
                      -- Se não encontrar registros
                      IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_crawcrd_cdgrafin;
                        
                        -- Buscar cartão liberado do próprio
                        OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                          -- pr_cdcooper
                                                 ,vr_nrdconta                          -- pr_nrdconta
                                                 ,NULL                                 -- pr_nrcctitg
                                                 ,NULL                                 -- pr_nrcpftit
                                                 ,3                                    -- pr_insitcrd -- LIBERADO
                                                 ,NULL );                              -- pr_flgprcrd
                        FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                     , vr_dddebito
                                                     , vr_vllimcrd
                                                     , vr_tpdpagto
                                                     , vr_flgdebcc;  
                        
                        -- Se não encontrar registros
                        IF cr_crawcrd_cdgrafin%NOTFOUND THEN
                          -- Buscar cartão liberado que tenha um outro cancelado na mesma data ( Ou seja: Up/Downgrade)
                          OPEN  cr_crawcrd_cancel(vr_cdcooper                 -- pr_cdcooper
                                                 ,vr_nrdconta                 -- pr_nrdconta
                                                 ,substr(vr_des_text,25,13)   -- pr_nrcctitg
                                                 ,3                           -- pr_insitcrd
                                                 ,rw_crapdat.dtmvtolt);       -- pr_dtmvtolt
                          FETCH cr_crawcrd_cancel INTO rw_crapacb.cdadmcrd
                                                     , vr_dddebito
                                                     , vr_vllimcrd
                                                     , vr_tpdpagto
                                                     , vr_flgdebcc;
                          -- Se não encontrar registros
                          IF cr_crawcrd_cancel%NOTFOUND THEN
                            CLOSE cr_crawcrd_cancel;                          
                            -- Buscar os dados do cartao
                            OPEN cr_crawcrd_cdgrafin_conta(vr_cdcooper               -- pr_cdcooper
                                                          ,vr_nrdconta               -- pr_nrdconta
                                                          ,substr(vr_des_text,25,13) -- pr_nrcctitg
                                                          ,rw_crapdat.dtmvtolt);     -- pr_dtmvtolt
                            -- Buscar os dados                              
                            FETCH cr_crawcrd_cdgrafin_conta INTO rw_crawcrd_cdgrafin_conta;
                            IF cr_crawcrd_cdgrafin_conta%FOUND THEN
                              CLOSE cr_crawcrd_cdgrafin_conta;
                              -- Carrega os dados do cartao
                              rw_crapacb.cdadmcrd := rw_crawcrd_cdgrafin_conta.cdadmcrd;
                              vr_dddebito         := rw_crawcrd_cdgrafin_conta.dddebito;
                              vr_vllimcrd         := rw_crawcrd_cdgrafin_conta.vllimcrd;
                              vr_tpdpagto         := rw_crawcrd_cdgrafin_conta.tpdpagto;
                              vr_flgdebcc         := rw_crawcrd_cdgrafin_conta.flgdebcc;                          
                            ELSE
                              CLOSE cr_crawcrd_cdgrafin_conta;
                              
                              IF cr_crawcrd_cdgrafin%ISOPEN THEN
                                CLOSE cr_crawcrd_cdgrafin;
                              END IF;
                              
                              OPEN  cr_crawcrd_cdgrafin(vr_cdcooper                 -- pr_cdcooper
                                                       ,vr_nrdconta                 -- pr_nrdconta
                                                       ,substr(vr_des_text,25,13)   -- pr_nrcctitg
                                                       ,NULL                        -- pr_nrcpftit
                                                       ,NULL                        -- pr_insitcrd -- EM USO
                                                       ,1);                         -- pr_flgprcrd
                              FETCH cr_crawcrd_cdgrafin INTO rw_crapacb.cdadmcrd
                                                           , vr_dddebito
                                                           , vr_vllimcrd
                                                           , vr_tpdpagto
                                                           , vr_flgdebcc;                                                                                         
                            END IF;
                            
                          ELSE
                            CLOSE cr_crawcrd_cancel;
                          END IF;
                                                     
                        END IF;
                      END IF;
                    END IF;
                  END IF;
                  
                  -- Fecha o cursor
                  CLOSE cr_crawcrd_cdgrafin;
                
                ELSE
                  -- busca Codigo da Adminstradora com base no Cod. do Grupo de Afinidade
                  OPEN cr_crapacb(pr_cdgrafin => vr_cdgrafin);
                  FETCH cr_crapacb INTO rw_crapacb;

                  IF cr_crapacb%NOTFOUND THEN
                    -- Fechar o cursor pois havera raise
                    CLOSE cr_crapacb;
                    -- Montar mensagem de critica
                    vr_dscritic := 'Cod. de Grupo de Afinidade ' || vr_cdgrafin || ' ' ||
                                   'nao encontrado. '||substr(vr_des_text,25,13);
                                   
                    -- gravar log do erro
                    pc_log_message;
                    -- Próxima linha
                    CONTINUE;
                  END IF;
                  -- Fecha cursor de Grupo de Afinidade
                  CLOSE cr_crapacb;

                END IF;
                
                -- Verifica se houve rejeição do Tipo de Registro 2
                IF substr(vr_des_text,211,3) <> '000'  THEN
                  /* nao deve solicitar cartao novamente caso retorne critica 080
                     (pessoa ja tem cartao nesta conta) */
                  IF substr(vr_des_text, 211, 3) = '080' THEN
                    continue;
                  END IF;
                  
                  BEGIN                  
                    vr_nmtitcrd := substr(vr_des_text,38,19)||substr(vr_des_text,57,23)||substr(vr_des_text,7,2);
                    INSERT INTO craprej
                       (cdcooper,
                        cdagenci,
                        cdpesqbb,
                        dshistor,
                        dtmvtolt,
                        cdcritic,
                        dtrefere,
                        nrdconta,
                        nrdctitg,
                        nrdocmto)
                    VALUES
                        (vr_cdcooper,
                         rw_crapass.cdagenci,
                         vr_nmtitcrd,
                         'CCR3',
                         rw_crapdat.dtmvtolt,
                         TO_NUMBER(substr(vr_des_text,211,3)),
                         TO_DATE(substr(vr_des_text,17,8),'DDMMYYYY'),
                         vr_nrdconta,
                         vr_nrdctitg,
                         TO_NUMBER(substr(vr_des_text,9,8)));
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir craprej: '||SQLERRM;
                      RAISE vr_exc_saida;
                    END;

                  -- Atualiza o campo cdpesqbb do tipo 1 com as inforamções de tipo 2 
                  atualiza_nmtitcrd(vr_cdcooper,
                                    rw_crapass.cdagenci,
                                    vr_nrdconta,
                                    rw_crapdat.dtmvtolt,
                                    vr_nmtitcrd); 
                      
                  -- Altera a situação da Proposta de Cartão para 1 (Aprovado)
                  altera_sit_cartao_aprovado(pr_cdcooper => vr_cdcooper,
                                             pr_nrdconta => vr_nrdconta,
                                             pr_nrseqcrd => vr_nroperac);
                                                
                  altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                       pr_nrdconta => vr_nrdconta,
                                       pr_nrseqcrd => vr_nroperac,
                                       pr_dtmvtolt => rw_crapdat.dtmvtolt);
                  
                  CONTINUE;
                ELSE
                  -- Atualiza a data de Rejeicao do contrato de Emprestimo
                  altera_data_rejeicao(pr_cdcooper => vr_cdcooper,
                                       pr_nrdconta => vr_nrdconta,
                                       pr_nrseqcrd => vr_nroperac,
                                       pr_dtmvtolt => NULL);
                    
                END IF;
                
                -- Para cada cartao, vamos buscar o valor de limite de credito cadastrado
                OPEN cr_craptlc(pr_cdcooper => vr_cdcooper,
                                pr_cdadmcrd => rw_crapacb.cdadmcrd,
                                pr_vllimcrd => vr_vllimcrd);
                FETCH cr_craptlc INTO rw_craptlc;
                IF cr_craptlc%FOUND THEN
                  CLOSE cr_craptlc;
                  vr_cdlimcrd := rw_craptlc.cdlimcrd;
                ELSE
                  CLOSE cr_craptlc;
                  vr_cdlimcrd := 0;
                  
                END IF;  

                -- Se o cursor estiver aberto
                IF cr_crawcrd%ISOPEN THEN
                  -- Fechar cursor
                  CLOSE cr_crawcrd;
                END IF;

                -- buscar proposta de cartão
                OPEN cr_crawcrd(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => vr_nrdconta,
                                pr_nrcpftit => TO_NUMBER(substr(vr_des_text,95,15)),
                                pr_cdadmcrd => rw_crapacb.cdadmcrd);
                FETCH cr_crawcrd INTO rw_crawcrd;

                -- se não encontrar proposta de cartão de crédito
                IF cr_crawcrd%NOTFOUND THEN
                  -- Busca dados do cooperado
                  OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                                  pr_nrdconta => vr_nrdconta);
                  FETCH cr_crapass INTO rw_crapass;

                  IF cr_crapass%FOUND THEN
                    IF rw_crapass.inpessoa = 1 THEN

                      -- Busca registro pessoa física
                      OPEN cr_crapttl(pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta,
                                      pr_nrcpfcgc => TO_NUMBER(substr(vr_des_text,95,15)));
                      FETCH cr_crapttl INTO rw_crapttl;

                      -- Se nao encontrar
                      IF cr_crapttl%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_crapttl;
                        -- Montar mensagem de critica
                        vr_dscritic := 'Titular nao encontrado da conta: ' || rw_crawcrd.nrdconta;
                        -- gravar log do erro
                        pc_log_message;

                        -- fecha cursor
                        CLOSE cr_crapass;
                        CLOSE cr_crawcrd;
                        CONTINUE;
                      ELSE
                        vr_nmextttl := rw_crapttl.nmextttl;
                        vr_vlsalari := rw_crapttl.vlsalari;
                        vr_dtnasccr := rw_crapass.dtnasctl;
                        -- Apenas fechar o cursor
                        CLOSE cr_crapttl;
                      END IF;
                    ELSE
                      -- Busca registro de pessoa jurídica
                      OPEN cr_crapjur(pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta);
                      FETCH cr_crapjur INTO rw_crapjur;

                      -- Se nao encontrar
                      IF cr_crapjur%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_crapjur;
                        -- Montar mensagem de critica
                        vr_dscritic := 'Empresa nao encontrada. Conta/DV: ' || rw_crapass.nrdconta;
                        -- gravar log do erro
                        pc_log_message;

                        -- fecha cursor 
                        CLOSE cr_crapass;
                        CLOSE cr_crawcrd;
                        CONTINUE;
                      ELSE
                        -- Apenas fechar o cursor
                        CLOSE cr_crapjur;
                      END IF;

                      -- Busca registro de representante para pessoa jurídica
                      OPEN cr_crapavt(pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta,
                                      pr_nrcpfcgc => TO_NUMBER(substr(vr_des_text,95,15)));
                      FETCH cr_crapavt INTO rw_crapavt;

                      -- Se nao encontrar
                      IF cr_crapavt%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_crapavt;
                        -- Montar mensagem de critica
                        vr_dscritic := 'Representante nao encontrado. Conta/DV: ' || rw_crapass.nrdconta ||
                                       ' CPF: '                                   || substr(vr_des_text,95,15);
                        -- gravar log do erro
                        pc_log_message;

                        -- fecha cursor 
                        CLOSE cr_crapass;
                        CLOSE cr_crawcrd;
                        CONTINUE;
                      ELSE
                        -- Apenas fechar o cursor
                        CLOSE cr_crapavt;
                      END IF;

                      -- Verifica se representante encontrado é cooperado
                      OPEN cr_crapass_avt(pr_cdcooper => rw_crapass.cdcooper,
                                          pr_nrcpfcgc => rw_crapavt.nrcpfcgc);
                      FETCH cr_crapass_avt INTO rw_crapass_avt;

                      -- Se nao for cooperado, pega os dados da tabela de representantes
                      IF cr_crapass_avt%NOTFOUND THEN
                        vr_nmextttl := rw_crapavt.nmdavali;
                        vr_vlsalari := 0;
                      ELSE -- Se for cooperado, pega os dados da conta
                        vr_nmextttl := rw_crapass_avt.nmprimtl;
                        vr_vlsalari := rw_crapass_avt.vlsalari;
                      END IF;

                      -- fechar o cursor
                      CLOSE cr_crapass_avt;
                    END IF;
                  ELSE
                    -- fechar os cursores
                    CLOSE cr_crapass;
                    CLOSE cr_crawcrd;
                    CONTINUE;
                  END IF;
                  -- fechar o cursor
                  CLOSE cr_crapass;

                  -- obter numero do contrato (sequencial)
                  vr_nrctrcrd := fn_sequence('CRAPMAT','NRCTRCRD', vr_cdcooper);

                  -- Verifica se é o primeiro cartão bancoob da empresa desta administradora
                  OPEN cr_crawcrd_flgprcrd(pr_cdcooper => vr_cdcooper,
                                           pr_nrdconta => vr_nrdconta,
                                           pr_cdadmcrd => rw_crapacb.cdadmcrd);
                  FETCH cr_crawcrd_flgprcrd INTO rw_crawcrd_flgprcrd;
                  IF cr_crawcrd_flgprcrd%FOUND THEN
                    -- Verificar se o CPF do titular do primeiro cartão é o mesmo que esta sendo validado
                    IF rw_crawcrd_flgprcrd.nrcpftit = TO_NUMBER(substr(vr_des_text,95,15)) THEN
                      vr_flgprcrd := 1; -- É o primeiro cartão Bancoob
                    ELSE
                      vr_flgprcrd := 0; -- Não é o primeiro
                    END IF;
                  ELSE
                     vr_flgprcrd := 1; -- É o primeiro cartão Bancoob
                  END IF;
                  -- fecha cursor
                  CLOSE cr_crawcrd_flgprcrd;
                  
                  /* Caso a Conta vinculada estiver 0, significa que o cartao eh do tipo OUTROS,
                     para os cartoes do tipo OUTROS sera puro CREDITO... */
                  IF to_number(TRIM(substr(vr_des_text,337,12))) = 0 THEN
                     vr_flgdebit := 0;
                  ELSE
                     vr_flgdebit := 1;
                  END IF;                  
                  
                  -- Deve buscar o contrato para inserir
                  vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(pr_cdcooper => vr_cdcooper);
                  
                  -- Cria nova proposta de cartão de crédito
                  BEGIN
                    INSERT INTO crawcrd
                       (nrdconta,
                        nrcrcard,
                        nrcctitg,
                        nrcpftit,
                        vllimcrd,
                        flgctitg,
                        dtmvtolt,
                        nmextttl,
                        flgprcrd,
                        tpdpagto,
                        flgdebcc,
                        tpenvcrd,
                        vlsalari,
                        dddebito,
                        cdlimcrd,
                        tpcartao,
                        dtnasccr,
                        nrdoccrd,
                        nmtitcrd,
                        nrctrcrd,
                        cdadmcrd,
                        cdcooper,
                        nrseqcrd,
                        dtpropos,
                        dtsolici,
                        flgdebit)
                    VALUES
                       (vr_nrdconta,                                      -- nrdconta
                        TO_NUMBER(substr(vr_des_text,38,19)),             -- nrcrcard
                        TO_NUMBER(substr(vr_des_text,25,13)),             -- nrcctitg
                        TO_NUMBER(substr(vr_des_text,95,15)),             -- nrcpftit
                        vr_vllimcrd,                                      -- vllimcrd
                        3,                                                -- flgctitg
                        rw_crapdat.dtmvtolt,                              -- dtmvtolt
                        vr_nmextttl,                                      -- nmextttl
                        vr_flgprcrd,                                      -- flgprcrd
                        vr_tpdpagto,                                      -- tpdpagto
                        vr_flgdebcc,                                      -- flgdebcc
                        0,                                                -- tpenvcrd
                        vr_vlsalari,                                      -- vlsalari
                        vr_dddebito,                                      -- dddebito
                        vr_cdlimcrd,                                      -- cdlimcrd
                        2,                                                -- tpcartao
                        TO_DATE(substr(vr_des_text,80,8), 'DDMMYYYY'),    -- dtnasccr
                        substr(vr_des_text,230,15),                       -- nrdoccrd
                        TRIM(substr(vr_des_text,57,23)),                  -- nmtitcrd
                        vr_nrctrcrd,                                      -- nrctrcrd
                        rw_crapacb.cdadmcrd,                              -- cdadmcrd
                        vr_cdcooper,                                      -- cdcooper
                        vr_nrseqcrd,                                      -- nrseqcrd
                        rw_crapdat.dtmvtolt,                              -- dtpropos
                        rw_crapdat.dtmvtolt,                              -- dtsolici
                        vr_flgdebit)                                      -- flgdebit
                        RETURNING ROWID INTO rw_crawcrd.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao inserir crawcrd: '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;

                  IF cr_crawcrd_rowid%ISOPEN THEN
                    CLOSE cr_crawcrd_rowid;
                  END IF;

                  -- Obtem ponteiro do registro de proposta recém criado
                  OPEN cr_crawcrd_rowid(pr_rowid => rw_crawcrd.rowid);
                  FETCH cr_crawcrd_rowid INTO rw_crawcrd;

                  IF cr_crapcrd%ISOPEN THEN
                    CLOSE cr_crapcrd;
                  END IF;
                  
                  -- buscar registro do cartão de crédito
                  OPEN cr_crapcrd(pr_cdcooper => rw_crawcrd.cdcooper,
                                  pr_nrdconta => rw_crawcrd.nrdconta,
                                  pr_nrcrcard => rw_crawcrd.nrcrcard);
                  FETCH cr_crapcrd INTO rw_crapcrd;

                  -- Se encontrar registro do cartão, cria log e continua
                  IF cr_crapcrd%FOUND THEN
                    -- LOGA NO PROC_MESSAGE
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> '
                                                               || 'CARTAO JA EXISTENTE - NR: ' || rw_crawcrd.nrcrcard || ' '
                                                               || 'CONTA: ' || rw_crawcrd.nrdconta || ' COOP.: ' || rw_crawcrd.cdcooper
                                                               || ' ARQ.: ' || vr_nmarquiv
                                              ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                    CONTINUE;
                  ELSE      
                    BEGIN
                      INSERT INTO crapcrd
                         (cdcooper,
                          nrdconta,
                          nrcrcard,
                          nrcpftit,
                          nmtitcrd,
                          dddebito,
                          cdlimcrd,
                          dtvalida,
                          nrctrcrd,
                          cdmotivo,
                          nrprotoc,
                          cdadmcrd,
                          tpcartao,
                          dtcancel,
                          flgdebit)
                      VALUES
                         (rw_crawcrd.cdcooper,
                          rw_crawcrd.nrdconta,
                          rw_crawcrd.nrcrcard,
                          rw_crawcrd.nrcpftit,
                          rw_crawcrd.nmtitcrd,
                          rw_crawcrd.dddebito,
                          rw_crawcrd.cdlimcrd,
                          rw_crawcrd.dtvalida,
                          rw_crawcrd.nrctrcrd,
                          rw_crawcrd.cdmotivo,
                          rw_crawcrd.nrprotoc,
                          rw_crawcrd.cdadmcrd,
                          rw_crawcrd.tpcartao,
                          rw_crawcrd.dtcancel,
                          rw_crawcrd.flgdebit)
                          RETURNING ROWID INTO rw_crapcrd.rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao inserir crapcrd: '||SQLERRM;
                        RAISE vr_exc_saida;
                    END;
                  END IF;
                    
                  -- fecha ponteiro do registro de proposta recém criado
                  CLOSE cr_crawcrd_rowid;

                  -- Fecha cursor de Cartão de crédito
                  CLOSE cr_crapcrd;

                ELSE -- se encontrar proposta de cartão de crédito   
                    
                  -- Se número do Cartão for zerado
                  IF rw_crawcrd.nrcrcard = 0 THEN
                    -- Atualiza registro de proposta de cartão se operação retornada for 01 ou 04
                    BEGIN
                      UPDATE crawcrd
                         SET nrcctitg = TO_NUMBER(substr(vr_des_text,25,13)),
                             nrcrcard = TO_NUMBER(substr(vr_des_text,38,19))
                       WHERE ROWID = rw_crawcrd.rowid;
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'Erro ao atualizar crawcrd: '||SQLERRM;
                        RAISE vr_exc_saida;
                    END;

                    IF cr_crawcrd_rowid%ISOPEN THEN
                      CLOSE cr_crawcrd_rowid;
                    END IF;

                    -- Obtem ponteiro do registro de proposta recém atualizado para alimentar a CRAPCRD corretamente
                    OPEN cr_crawcrd_rowid(pr_rowid => rw_crawcrd.rowid);
                    FETCH cr_crawcrd_rowid INTO rw_crawcrd;

                    IF cr_crapcrd%ISOPEN THEN
                      CLOSE cr_crapcrd;
                    END IF;

                    -- buscar registro do cartão de crédito
                    OPEN cr_crapcrd(pr_cdcooper => rw_crawcrd.cdcooper,
                                    pr_nrdconta => rw_crawcrd.nrdconta,
                                    pr_nrcrcard => rw_crawcrd.nrcrcard);
                    FETCH cr_crapcrd INTO rw_crapcrd;

                    -- Se não encontrar registro do cartão de crédito,
                    IF cr_crapcrd%NOTFOUND THEN
                      -- Cria registro de Cartão de Crédito
                      BEGIN
                        INSERT INTO crapcrd
                           (cdcooper,
                            nrdconta,
                            nrcrcard,
                            nrcpftit,
                            nmtitcrd,
                            dddebito,
                            cdlimcrd,
                            dtvalida,
                            nrctrcrd,
                            cdmotivo,
                            nrprotoc,
                            cdadmcrd,
                            tpcartao,
                            dtcancel,
                            flgdebit)
                        VALUES
                           (rw_crawcrd.cdcooper,
                            rw_crawcrd.nrdconta,
                            rw_crawcrd.nrcrcard,
                            rw_crawcrd.nrcpftit,
                            rw_crawcrd.nmtitcrd,
                            rw_crawcrd.dddebito,
                            rw_crawcrd.cdlimcrd,
                            rw_crawcrd.dtvalida,
                            rw_crawcrd.nrctrcrd,
                            rw_crawcrd.cdmotivo,
                            rw_crawcrd.nrprotoc,
                            rw_crawcrd.cdadmcrd,
                            rw_crawcrd.tpcartao,
                            rw_crawcrd.dtcancel,
                            rw_crawcrd.flgdebit)
                            RETURNING ROWID INTO rw_crapcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crapcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                      
                    ELSE -- se encontrar registro do cartão de crédito,

                      -- Atualiza registro de cartão de crédito
                      BEGIN
                        UPDATE crapcrd
                           SET nrcrcard = TO_NUMBER(substr(vr_des_text,38,19))
                         WHERE ROWID = rw_crapcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao atualizar crapcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;

                    END IF;

                    -- Fecha cursor de Cartão de crédito
                    CLOSE cr_crapcrd;

                    -- fecha ponteiro do registro de proposta recém atualizada
                    CLOSE cr_crawcrd_rowid;

                  ELSE -- Se o número do Cartão não for zerado (tratamento 2a. via)

                    -- Ignora registro caso o cartão obtido no arquivo já estiver
                    -- cadastrado na base de dados
                    IF (TO_NUMBER(substr(vr_des_text,38,19)) = rw_crawcrd.nrcrcard) THEN
                      CLOSE cr_crawcrd;
                      CONTINUE;
                    END IF;
                    
                    -- Limpar variáveis
                    rw_crapacb.cdadmcrd := NULL;
                    
                    -- Buscar operadora do cartão solicitado via Upgrade/Downgrade
                    OPEN  cr_crawcrd_ativo(vr_cdcooper                 --pr_cdcooper
                                          ,vr_nrdconta                 --pr_nrdconta
                                          ,substr(vr_des_text,25,13)   --pr_nrcctitg
                                          ,TO_NUMBER(substr(vr_des_text,95,15))
                                          ,rw_crawcrd.rowid) ;
                    FETCH cr_crawcrd_ativo INTO rw_crapacb.cdadmcrd
                                              , vr_dddebito
                                              , vr_vllimcrd
                                              , vr_tpdpagto
                                              , vr_flgdebcc;
                    -- Se não encontrar registro, caracteriza uma segunda via
                    IF cr_crawcrd_ativo%NOTFOUND THEN
                      vr_dtentr2v := rw_crapdat.dtmvtolt;
                    ELSE
                      vr_dtentr2v := NULL;
                    END IF;                    
                    
                    CLOSE cr_crawcrd_ativo;
                   
                    -- Se o cursor estiver aberto
                    IF cr_crawcrd%ISOPEN THEN
                      -- Fechar cursor
                      CLOSE cr_crawcrd;
                    END IF;
                    
                    -- buscar proposta de cartão
                    OPEN cr_crawcrd(pr_cdcooper => vr_cdcooper,
                                    pr_nrdconta => vr_nrdconta,
                                    pr_nrcpftit => TO_NUMBER(substr(vr_des_text,95,15)),
                                    pr_cdadmcrd => rw_crapacb.cdadmcrd,
                                    pr_rowid    => rw_crawcrd.rowid);
                    FETCH cr_crawcrd INTO rw_crawcrd;
                    
                    -- Se não encontrar o cartão solicitado
                    IF cr_crawcrd%NOTFOUND THEN
                      
                      -- obter numero do contrato (sequencial)
                      vr_nrctrcrd := fn_sequence('CRAPMAT','NRCTRCRD', vr_cdcooper);
                      
                      -- Deve buscar o contrato para inserir
                      vr_nrseqcrd := CCRD0003.fn_sequence_nrseqcrd(pr_cdcooper => vr_cdcooper);
                      
                      -- olha o indicador de funcao debito direto na linha que esta sendo processada
                      IF to_number(TRIM(substr(vr_des_text,337,12))) = 0 THEN
                        vr_flgdebit := 0;
                      ELSE
                        vr_flgdebit := 1;
                      END IF;
                  
                      -- cria nova proposta com número do cartão vindo no arquivo
                      BEGIN
                        INSERT INTO crawcrd
                           (nrdconta,
                            nrcrcard,
                            nrcctitg,
                            nrcpftit,
                            vllimcrd,
                            flgctitg,
                            dtmvtolt,
                            nmextttl,
                            flgprcrd,
                            tpdpagto,
                            flgdebcc,
                            tpenvcrd,
                            vlsalari,
                            dddebito,
                            cdlimcrd,
                            tpcartao,
                            dtnasccr,
                            nrdoccrd,
                            nmtitcrd,
                            nrctrcrd,
                            cdadmcrd,
                            cdcooper,
                            nrseqcrd,
                            dtentr2v,
                            dtpropos,
                            flgdebit,
                            nmempcrd)
                        VALUES
                           (rw_crawcrd.nrdconta,
                            TO_NUMBER(substr(vr_des_text,38,19)), -- número cartão vindo do arquivo
                            rw_crawcrd.nrcctitg,
                            rw_crawcrd.nrcpftit,
                            rw_crawcrd.vllimcrd,
                            rw_crawcrd.flgctitg,
                            rw_crawcrd.dtmvtolt,
                            rw_crawcrd.nmextttl,
                            rw_crawcrd.flgprcrd, -- Não é primeiro cartão Bancoob
                            rw_crawcrd.tpdpagto,
                            rw_crawcrd.flgdebcc,
                            rw_crawcrd.tpenvcrd,
                            rw_crawcrd.vlsalari,
                            rw_crawcrd.dddebito,
                            rw_crawcrd.cdlimcrd,
                            rw_crawcrd.tpcartao,
                            rw_crawcrd.dtnasccr,
                            rw_crawcrd.nrdoccrd,
                            rw_crawcrd.nmtitcrd,
                            vr_nrctrcrd, --rw_crawcrd.nrctrcrd,
                            rw_crawcrd.cdadmcrd,
                            rw_crawcrd.cdcooper,
                            vr_nrseqcrd,
                            vr_dtentr2v,
                            rw_crapdat.dtmvtolt,
                            vr_flgdebit,
                            rw_crawcrd.nmempcrd)
                            RETURNING ROWID INTO rw_crawcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crawcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                    ELSE
                      
                      -- Atualiza registro de proposta de cartão se operação retornada for 01 ou 04
                      BEGIN
                        UPDATE crawcrd
                           SET nrcrcard = TO_NUMBER(substr(vr_des_text,38,19))
                         WHERE ROWID = rw_crawcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro[2] ao atualizar crawcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                    
                    END IF; 

                    IF cr_crawcrd_rowid%ISOPEN THEN
                      CLOSE cr_crawcrd_rowid;
                    END IF;

                    -- Obtem ponteiro do registro de proposta recém criado
                    OPEN cr_crawcrd_rowid(pr_rowid => rw_crawcrd.rowid);
                    FETCH cr_crawcrd_rowid INTO rw_crawcrd;

                    IF cr_crapcrd%ISOPEN THEN
                      CLOSE cr_crapcrd;
                    END IF;

                    -- buscar registro do cartão de crédito
                    OPEN cr_crapcrd(pr_cdcooper => rw_crawcrd.cdcooper,
                                    pr_nrdconta => rw_crawcrd.nrdconta,
                                    pr_nrcrcard => rw_crawcrd.nrcrcard);
                    FETCH cr_crapcrd INTO rw_crapcrd;

                    -- Se encontrar registro do cartão, cria log e continua
                    IF cr_crapcrd%FOUND THEN
                      -- LOGA NO PROC_MESSAGE
                      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                                 || vr_cdprogra || ' --> '
                                                                 || 'CARTAO JA EXISTENTE - NR: ' || rw_crawcrd.nrcrcard || ' '
                                                                 || 'CONTA: ' || rw_crawcrd.nrdconta || ' COOP.: ' || rw_crawcrd.cdcooper
                                                                 || ' ARQ.: ' || vr_nmarquiv
                                                ,pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                      CONTINUE;
                    ELSE
                      -- cria novo registro de cartão de crédito
                      BEGIN
                        INSERT INTO crapcrd
                           (cdcooper,
                            nrdconta,
                            nrcrcard,
                            nrcpftit,
                            nmtitcrd,
                            dddebito,
                            cdlimcrd,
                            dtvalida,
                            nrctrcrd,
                            cdmotivo,
                            nrprotoc,
                            cdadmcrd,
                            tpcartao,
                            dtcancel,
                            flgdebit)
                        VALUES
                           (rw_crawcrd.cdcooper,
                            rw_crawcrd.nrdconta,
                            rw_crawcrd.nrcrcard,
                            rw_crawcrd.nrcpftit,
                            rw_crawcrd.nmtitcrd,
                            rw_crawcrd.dddebito,
                            rw_crawcrd.cdlimcrd,
                            rw_crawcrd.dtvalida,
                            rw_crawcrd.nrctrcrd,
                            rw_crawcrd.cdmotivo,
                            rw_crawcrd.nrprotoc,
                            rw_crawcrd.cdadmcrd,
                            rw_crawcrd.tpcartao,
                            rw_crawcrd.dtcancel,
                            rw_crawcrd.flgdebit)
                            RETURNING ROWID INTO rw_crapcrd.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          vr_dscritic := 'Erro ao inserir crapcrd: '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                    
                    END IF;                    
                    
                    -- Fecha cursor de Cartão de crédito
                    CLOSE cr_crapcrd;
                                        
                    -- fecha ponteiro do registro de proposta recém criado
                    CLOSE cr_crawcrd_rowid;

                  END IF;
                END IF;

                -- Fecha cursor de proposta de cartão de crédito
                CLOSE cr_crawcrd;

                -- Atualiza situação da proposta de cartão de crédito
                BEGIN
                  UPDATE crawcrd
                     SET insitcrd = 3 -- Liberado
                       , dtentreg = NULL
                       , inanuida = 0
                       , qtanuida = 0
                       , dtlibera = trunc(SYSDATE)
                       -- cdoperad = pr_cdoperad  -- Não deve sobrescrever o operador ( Renato - Supero )
                   WHERE ROWID = rw_crawcrd.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar situacao da crawcrd: '||SQLERRM;
                    RAISE vr_exc_saida;
                END;

              END IF;
            EXCEPTION
              WHEN no_data_found THEN -- não encontrar mais linhas
                EXIT;
              WHEN OTHERS THEN
                IF vr_dscritic IS NULL THEN
                  vr_dscritic := 'Erro arquivo ['|| vr_vet_nmarquiv(i) ||']: '||SQLERRM;
                END IF;
                RAISE vr_exc_saida;
            END;
          END LOOP;

          -- Fechar o arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;

          -- Montar Comando para copiar o arquivo lido para o diretório recebidos do CONNECT
          vr_comando:= 'cp '|| vr_direto_connect || '/' || vr_vet_nmarquiv(i) ||
                       ' '  || rw_crapscb.dsdirarq || '/recebidos/ 2> /dev/null';

          -- Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_dscritic);

          -- Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            RAISE vr_exc_saida;
          END IF;

          -- Montar Comando para mover o arquivo lido para o diretório salvar
          vr_comando:= 'mv '|| vr_direto_connect || '/' || vr_vet_nmarquiv(i) ||
                       ' '|| vr_dsdireto || '/salvar/ 2> /dev/null';

          -- Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                               ,pr_des_comando => vr_comando
                               ,pr_typ_saida   => vr_typ_saida
                               ,pr_des_saida   => vr_dscritic);

          -- Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            RAISE vr_exc_saida;
          END IF;

          -- ATUALIZA REGISTRO REFERENTE A SEQUENCIA DE ARQUIVOS
          IF nvl(vr_nrseqarq_max,0) > nvl(rw_crapscb.nrseqarq,0) THEN
            BEGIN
              UPDATE crapscb
                 SET dtultint = SYSDATE,
                     nrseqarq = vr_nrseqarq_max
              WHERE crapscb.rowid = rw_crapscb.rowid;

            -- VERIFICA SE HOUVE PROBLEMA NA ATUALIZACAO DE REGISTROS
            EXCEPTION
              WHEN OTHERS THEN
                -- DESCRICAO DO ERRO NA INSERCAO DE REGISTROS
                vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSCB: ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
          END IF;

          -- Apos processar o arquivo, deve realizar o commit,
          -- pois já movel para a pasta recebidos
          COMMIT;

        END IF;

      END LOOP;
      
      -- Adiciona a linha ao XML
      pc_escreve_xml(vr_xml_lim_cartao,'</crrl707>');

      -- Apaga o arquivo pc_crps672.txt no unix
      vr_comando:= 'rm ' || vr_direto_connect || '/pc_crps672.txt 2> /dev/null';
      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;

      -- GERAÇÃO DE RELATÓRIO DE REJEIÇÕES DA LEITURA DO ARQUIVO DE RETORNO

      -- Percorre todos os registros retornados pelo cursor
      FOR rw_crapcop_todas IN cr_crapcop_todas LOOP
        -- Preparar o CLOB para armazenar as infos do arquivo
        dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
        dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
        pc_escreve_xml(vr_xml_clobxml, '<?xml version="1.0" encoding="utf-8"?>'||chr(10)||'<crrl676>'||chr(10));

        vr_pa_anterior  := 0;
       
        vr_pa_proximo   := false;
        FOR rw_craprej IN cr_craprej(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_cdcooper => rw_crapcop_todas.cdcooper) LOOP          
         
          
          IF vr_pa_anterior <> rw_craprej.cdagenci THEN
             IF vr_pa_proximo THEN 
                pc_escreve_xml(vr_xml_clobxml,'</agencia>');
             END IF ;            
             pc_escreve_xml (vr_xml_clobxml,'<agencia cdagenci="'||rw_craprej.cdagenci||'" nmextage="'||rw_craprej.nmextage||'">');
             vr_pa_proximo := true;      
            
          END IF;  
          
          vr_pa_anterior  := rw_craprej.cdagenci;
          

        -- Adiciona a linha ao XML
        pc_escreve_xml (vr_xml_clobxml,'<rejeitados>'
               ||chr(10)||'<cdcooper>'||rw_craprej.cdcooper||'</cdcooper>'
               ||chr(10)||'<nmtitcrd>'||NVL(TRIM(rw_craprej.nmtitcrd), ' ') ||'</nmtitcrd>'
               ||chr(10)||'<cdpesqbb>'||TRIM(rw_craprej.cdpesqbb)||'</cdpesqbb>'
               ||chr(10)||'<nrdocmto>'||TRIM(gene0002.fn_mask(rw_craprej.nrdocmto,'zz.zzz.zzz'))||'</nrdocmto>'
               ||chr(10)||'<nrdconta>'||TRIM(gene0002.fn_mask(rw_craprej.nrdconta,'zzzz.zzz.z'))||'</nrdconta>'
               ||chr(10)||'<nrdctitg>'||TRIM(to_char(rw_craprej.nrdctitg))||'</nrdctitg>'
               ||chr(10)||'<cdtipope>'||TRIM(rw_craprej.cdtipope) || '-' ||  vr_vet_nmtipsol(rw_craprej.cdtipope) ||'</cdtipope>'
               ||chr(10)||'<cdcritic>'||TRIM(REPLACE(rw_craprej.cdcritic,',',chr(10))) ||'</cdcritic>'
               ||chr(10)||'</rejeitados>');

        IF vr_pa_anterior <> rw_craprej.cdagenci THEN             
             pc_escreve_xml (vr_xml_clobxml,'</agencia>');
             vr_pa_proximo := FALSE;
          END IF;  

        END LOOP;
        
       IF vr_pa_anterior > 0 AND  vr_pa_proximo = TRUE THEN
         pc_escreve_xml (vr_xml_clobxml,'</agencia>');
       END IF;
       
        
      -- Adiciona a linha ao XML
       pc_escreve_xml(vr_xml_clobxml,'</crrl676>');

     -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'M'         --> /usr/micros
                                          ,pr_cdcooper => rw_crapcop_todas.cdcooper
                                          ,pr_nmsubdir => null); 
                                          
      --  Salvar copia relatorio para "/rlnsv"
      vr_dsdireto_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                               ,pr_cdcooper => rw_crapcop_todas.cdcooper
                                               ,pr_nmsubdir => 'rlnsv');
      
      vr_dsdirarq := vr_dsdireto||'/cecred_cartoes/crrl676_'||to_char(rw_crapdat.dtmvtolt,'DDMMYYYY')||'.pdf';                                
      
      -- Submeter o relatório 676
      gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop_todas.cdcooper            --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl676/agencia   '                --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl676.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdirarq                          --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 234 colunas
                                 ,pr_flg_gerar => 'S'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '676'                               --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                 ,pr_dspathcop => vr_dsdireto_rlnsv                    --> Enviar para o rlnsv
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_clobxml);
      dbms_lob.freetemporary(vr_xml_clobxml);
      
      END LOOP;

      -- Verifica se ocorreram erros na geração do XML
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := vr_xml_des_erro;
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
      
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'M'         --> /usr/micros
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => null); 
                                          
      vr_dsdirarq := vr_dsdireto || '/cecred_cartoes/crrl707_'||to_char(rw_crapdat.dtmvtolt,'DDMMYYYY');
      
      -- Submeter o relatório 676
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_lim_cartao   --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl707/Dados'    --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl707.jasper'    --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdirarq ||'.lst'--> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                 --> 134 colunas
                                 ,pr_flg_gerar => 'S'                 --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132dm'             --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                   --> Número de cópias
                                 ,pr_sqcabrel  => 1                   --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '707'               --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                 ,pr_des_erro  => vr_dscritic);       --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_lim_cartao);
      dbms_lob.freetemporary(vr_xml_lim_cartao);
      
      -- Gera a impressao pelo SCRIPT para ficar formatado a margen no PDF
      GENE0002.pc_gera_pdf_impressao(pr_cdcooper => pr_cdcooper
                                    ,pr_nmarqimp => vr_dsdirarq ||'.lst'
                                    ,pr_nmarqpdf => vr_dsdirarq ||'.pdf'
                                    ,pr_des_erro => vr_dscritic);
                                    
      -- Se existir arquivo, limpar pcl
      IF GENE0001.fn_exis_arquivo(vr_dsdirarq ||'.lst') THEN
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdirarq ||'.lst 2>/dev/null'
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);
      END IF;                                  

      BEGIN
        -- Excluir registros
        DELETE craprej
         WHERE craprej.dtmvtolt = rw_crapdat.dtmvtolt
           AND craprej.dshistor = 'CCR3';

      EXCEPTION
        WHEN OTHERS THEN
          -- Buscar descricão do erro
          vr_dscritic := 'Erro ao excluir craprej: '||SQLERRM;
          -- Envio centralizado de log de erro
          RAISE vr_exc_saida;
      END;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN

       pc_log_message;

        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
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
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;

    END;

END PC_CRPS672;
/
