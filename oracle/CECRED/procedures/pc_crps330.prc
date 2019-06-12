CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS330(pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                             ,pr_dscritic OUT varchar2) IS          --> Texto de erro/critica encontrada


  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: PC_CRPS330
  --  Autor   : Andrino Carlos de Souza Junior (RKAM)
  --  Data    : Novembro/2015                     Ultima Atualizacao: - 12/06/2019
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Envio de negativacoes para a Serasa
  --
  --  Alteracoes: 13/03/2016 - Ajustes decorrente a mudança de algumas rotinas da PAGA0001 
  --               para a COBR0006 em virtude da conversão das rotinas de arquivos CNAB
  --               (Andrei - RKAM). 
  --
  --              20/06/2016 - Enviar todos os dados na primeira linha de cada registro. Antes o 
  --                           numero da conta ia somente na segunda linha
  --
  --              04/07/2016 - Nao enviar para o Serasa automaticamente se ja foi enviado uma vez
  --                           (Chamado 480923 - Andrino - RKAM)
  --
  --              21/11/2016 - Ajustado cursor do cr_crapsab para retornar espaço em branco caso o campo possua
  --                           valor NULL (Douglas - Chamado 560819)
  --
  --              30/01/2017 - Ajustado para que seja enviado ao Serasa a informacao de conta e documento que estao
  --                           no campo nosso numero, para que os boletos que sao de contas migradas sejam enviados
  --                           com a conta antiga (Douglas - Chamado 602825)
  --
  --              30/03/2017 - #551229 Job ENVIO_SERASA excluído para a criação dos jobs JBCOBRAN_ENVIO_SERASA e JBCOBRAN_RECEBE_SERASA.
  --                           Log de início, fim e erros na execução do job. (Carlos)
  --
  --              04/07/2017 - #701001 Correção do parametro cdcritic para dscritic na rotina fn_busca_critica
  --                           da exception vr_exc_saida (Carlos)
  --
  --              22/04/2019 - Alterar a regra de negativação para o Serasa por estado. Permitir parametrizar a quantidade
  --                           de dias desejado.
  --                           Jose Dill (Mouts). Requisição - RITM0012246 
  /*
                  12/06/2019 - INC0017147 Na rotina pc_clob_para_arquivo, ao ocorrer erro, decrementar a sequencia do
                               arquivo e seguir o fluxo do processo (Carlos)
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Atualiza a situacao do boleto como enviada
  PROCEDURE pc_atualiza_situacao(pr_rowid    IN  ROWID,
                                 pr_cdcooper IN  crapcob.cdcooper%TYPE,
                                 pr_cdbandoc IN  crapcob.cdbandoc%TYPE,
                                 pr_nrdctabb IN  crapcob.nrdctabb%TYPE,
                                 pr_nrcnvcob IN  crapcob.nrcnvcob%TYPE,
                                 pr_nrdconta IN  crapcob.nrdconta%TYPE,
                                 pr_nrdocmto IN  crapcob.nrdocmto%TYPE,
                                 pr_inserasa IN  crapcob.inserasa%TYPE,
                                 pr_dscritic OUT VARCHAR2) IS

       --Variaveis de controle do programa
       vr_cdcritic    NUMBER:= 0;
       vr_dscritic    VARCHAR2(4000);
       vr_des_erro    VARCHAR2(10);

       --Variaveis de Excecao
       vr_exc_saida  EXCEPTION;

    BEGIN
      -- Altera a situacao para enviada
      BEGIN
        UPDATE crapcob
           SET inserasa = decode(pr_inserasa,1,2 --Solicitacao Enviada
                                              ,4)--Solicitacao Cancel. Enviada
         WHERE ROWID = pr_rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar CRAPCOB: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Insere o historico da movimentacao
      BEGIN
        INSERT INTO tbcobran_his_neg_serasa
          (cdcooper
          ,cdbandoc
          ,nrdctabb
          ,nrcnvcob
          ,nrdconta
          ,nrdocmto
          ,nrsequencia
          ,dhhistorico
          ,inserasa
          ,cdoperad)
        VALUES
          (pr_cdcooper
          ,pr_cdbandoc
          ,pr_nrdctabb
          ,pr_nrcnvcob
          ,pr_nrdconta
          ,pr_nrdocmto
          ,(SELECT nvl(MAX(nrsequencia),0)+1 FROM tbcobran_his_neg_serasa
                                            WHERE cdcooper = pr_cdcooper
                                              AND cdbandoc = pr_cdbandoc
                                              AND nrdctabb = pr_nrdctabb
                                              AND nrcnvcob = pr_nrcnvcob
                                              AND nrdconta = pr_nrdconta
                                              AND nrdocmto = pr_nrdocmto)
          ,SYSDATE
          ,decode(pr_inserasa,1,2 --Solicitacao Enviada
                                       ,4)--Solicitacao Cancel. Enviada
          ,'1');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir na tbcobran_his_neg_serasa: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Se for envio de negativacao
      IF pr_inserasa = 1 THEN
        -- Inserir log de envio da negativacao
        paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_rowid,
                                      pr_cdoperad => '1',
                                      pr_dtmvtolt => trunc(SYSDATE), -- Rotina nao utiliza esta data
                                      pr_dsmensag => 'Boleto enviado para negativacao',
                                      pr_des_erro => vr_des_erro,
                                      pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      ELSE
        -- Inserir log de envio do cancelamento da negativacao
        paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_rowid,
                                      pr_cdoperad => '1',
                                      pr_dtmvtolt => trunc(SYSDATE), -- Rotina nao utiliza esta data
                                      pr_dsmensag => 'Envio do cancelamento de negativacao do boleto - Serasa',
                                      pr_des_erro => vr_des_erro,
                                      pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      END IF;
    EXCEPTION
       WHEN vr_exc_saida THEN
         -- Devolvemos código e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
       WHEN OTHERS THEN
         cecred.pc_internal_exception(3);
         -- Efetuar retorno do erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := SQLERRM;
    END;

  BEGIN


--********************************
--/* INICIO DA ROTINA PRINCIPAL */
--********************************
     DECLARE

       /* Cursores da pc_crps330 */
       
       -- Cursor sobre data
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;

       vr_idprglog tbgen_prglog.idprglog%TYPE := 0;

       -- Loop sobre as cooperativas ativas
       CURSOR cr_crapcop IS
         SELECT cdcooper,
                cdbcoctl,
                cdagebcb,
                cdagectl, 
                substr(lpad(nrdocnpj,15,'0'),1,9) nrdocnpj,
                nrdocnpj nrdocnpj_completo,
                dsendweb,
                SUBSTR(nmrescop,1,15) AS nmrescop,
                SUBSTR(nrtelvoz,2,INSTR(nrtelvoz,')')-2) AS nrdddtel,
                REPLACE(substr(nrtelvoz,INSTR(nrtelvoz,')')+1),'-','') AS nrtelvoz,
                SUBSTR(nrdocnpj,-6,6) AS nrdigito,
                cdcliser
           FROM crapcop
          WHERE flgativo = 1;
 
       -- Busca os boletos pendentes
       CURSOR cr_crapcob(pr_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT ROWID,
                cdbandoc,
                nrdctabb,
                nrcnvcob,
                nrdconta,
                nrdocmto,
                cdcooper,
                nrinssac,
                nrnosnum,
                to_char(nvl(dtdocmto,dtmvtolt),'yyyymmdd') AS dtdocmto,
                dtvencto,
                vltitulo,
                cddespec,
                cdcartei,
                tpdmulta,
                tpjurmor,
                vlabatim,
                vlrmulta,
                vljurdia,
                incobran,
                inserasa,
                dsdoccop
           FROM crapcob a
          WHERE a.cdcooper = pr_cdcooper
            AND a.inserasa IN (1,  -- Pendente envio
                               3); -- Pendente envio cancelamento

       -- Busca os boletos para negativado apos a quantidade de dias de recebimento 
       -- da Serasa
       CURSOR cr_crapcob_2(pr_cdcooper crapcop.cdcooper%TYPE,
                           pr_dtmvtolt DATE) IS               
         SELECT b.rowid,
                c.cdagenci,
                c.cdbccxlt,
                c.nrdolote,
                c.nrconven
           FROM crapcco c,
                crapcob b,
                tbcobran_param_negativacao a,
                crapsab sab,
                tbcobran_param_exc_neg_serasa exc                
          WHERE a.cdcooper = pr_cdcooper
            AND b.cdcooper = a.cdcooper
            AND b.inserasa = 2
            --AND b.dtretser + a.qtdias_negativacao <= pr_dtmvtolt
            AND b.dtretser + DECODE(exc.dsuf,NULL,a.qtdias_negativacao,exc.qtminimo_negativacao) <= pr_dtmvtolt
            /*RITM0012246 - Incluído as tabelas crapsab e tbcobran_param_exc_neg_serasa para permitir utilizar 
              a quantidade de dias para negativação parametrizada na TAB097 associada a um estado. Desta forma,
              será considerado a qtde dias informada para o estado, caso o mesmo esteja cadastrado. Se não estiver
              continuára utilizando o valor padrão cadastrado na TAB097, como é feito atualmente */
            AND c.cdcooper = b.cdcooper
            AND c.nrconven = b.nrcnvcob
            --
            AND sab.cdcooper = b.cdcooper
            AND sab.nrdconta = b.nrdconta
            AND sab.nrinssac = b.nrinssac
            AND sab.cdufsaca = exc.dsuf (+)
            AND 3            = exc.indexcecao (+); 
       
       
       -- Busca Dados do Credor
       CURSOR cr_crapjur(pr_cdcooper crapcop.cdcooper%TYPE,
                         pr_nrdconta crapjur.nrdconta%TYPE) IS 
         SELECT ass.nrcpfcgc, --> Documento do Credor 
                gene0007.fn_caract_acento(pr_texto => jur.nmextttl) nmextttl, --> Razão Social do Credor   
                gene0007.fn_caract_acento(pr_texto => jur.nmfansia) nmfansia, --> Nome Fantasia do Credor
                gene0007.fn_caract_acento(pr_texto => enc.dsendere) dsendere, --> Endereço do Credor
                gene0007.fn_caract_acento(pr_texto => enc.nmbairro) nmbairro, --> Bairro do Credor
                gene0007.fn_caract_acento(pr_texto => enc.nmcidade) nmcidade, --> Município do Credor 
                enc.cdufende, --> Sigla Unidade Federativa do Credor    
                enc.nrcepend, --> Código de endereçamento postal
                nvl(tfc.nrdddtfc,0) nrdddtfc, --> DDD do Telefone do Credor
                nvl(tfc.nrtelefo,0) nrtelefo, --> Telefone do Credor
                nvl(tfc.nrdramal,0) nrdramal  --> Número de ramal do telefone do Credor 
          FROM crapass ass, 
               crapenc enc, 
               craptfc tfc,
               crapjur jur
          WHERE jur.cdcooper = pr_cdcooper 
            AND jur.nrdconta = pr_nrdconta 
            AND ass.cdcooper = jur.cdcooper 
            AND ass.nrdconta = jur.nrdconta
            AND enc.cdcooper = jur.cdcooper 
            AND enc.nrdconta = jur.nrdconta 
            AND tfc.cdcooper (+)= jur.cdcooper 
            AND tfc.nrdconta (+)= jur.nrdconta 
            AND tfc.idseqttl (+)= 1;
        rw_crapjur cr_crapjur%ROWTYPE;
       
       -- Busca Dados do Devedor
       CURSOR cr_crapsab(pr_cdcooper crapsab.cdcooper%TYPE,
                         pr_nrdconta crapsab.nrdconta%TYPE,
                         pr_nrinssac crapsab.nrinssac%TYPE) IS                  
        SELECT cdtpinsc, --> Tipo de pessoa do Devedor (F - Fisica / J - Juridica)
               nrinssac, --> Documento do Devedor (CPF ou CNPJ)
               NVL(gene0007.fn_caract_acento(pr_texto => nmdsacad), ' ') nmdsacad, --> Nome do Devedor
               NVL(gene0007.fn_caract_acento(pr_texto => dsendsac), ' ') dsendsac, --> Endereço do Devedor
               NVL(gene0007.fn_caract_acento(pr_texto => complend), ' ') complend, --> Complemento do Endereço do Devedor
               NVL(gene0007.fn_caract_acento(pr_texto => nmbaisac), ' ') nmbaisac, --> Bairro do Devedor
               NVL(gene0007.fn_caract_acento(pr_texto => nmcidsac), ' ') nmcidsac, --> Município do Devedor
               NVL(cdufsaca, ' ') cdufsaca, --> Sigla Unidade Federativa do Devedor
               NVL(nrcepsac, 0) nrcepsac  --> CEP do Devedor
          FROM crapsab
          WHERE cdcooper = pr_cdcooper 
            AND nrdconta = pr_nrdconta 
            AND nrinssac = pr_nrinssac;
       rw_crapsab cr_crapsab%ROWTYPE;
       
       -- Busca os dias de vencimento
       CURSOR cr_param(pr_cdcooper crapcop.cdcooper%TYPE) IS
         SELECT qtdias_vencimento
           FROM tbcobran_param_negativacao
          WHERE cdcooper = pr_cdcooper;
       rw_param cr_param%ROWTYPE;

       -- Variaveis Locais da pc_crps330
       vr_dsdireto    VARCHAR2(300); -- Diretorio onde sera gerado o arquivo
       vr_nmarquiv    VARCHAR2(50); -- Nome do arquivo
       vr_dsserasa    VARCHAR2(10);
       vr_dstpinsc    VARCHAR2(10);
       vr_nrtpinsc    VARCHAR2(10);
       vr_nrseqblt    NUMBER:= 1;    -- Numero Sequencial do Boleto
       vr_dsdespec    VARCHAR2(10);  -- Especia do Titulo
       vr_tab_cob     cecred.cobr0005.typ_tab_cob;
       vr_dstxtpgt    VARCHAR2(70):='PAGAVEL PREFERENCIALMENTE NAS COOPERATIVAS DO SISTEMA AILOS.';
       vr_dtvencto    DATE; -- Data de vencimento calculada
       vr_cdbarras    VARCHAR2(100); -- Codigo de barras
       vr_lindigit    VARCHAR2(100); -- Linha digitavel do codigo de barras
       vr_vlfatura    crapcob.vltitulo%TYPE; -- Valor da fatura para o calculo do valor com multa
       vr_vlrmulta    crapcob.vltitulo%TYPE; -- Valor da multa
       vr_vlrjuros    crapcob.vltitulo%TYPE; -- Valor dos juros
       vr_nrdigage    NUMBER(05); -- Digito da agencia
       vr_lixo        BOOLEAN; -- Variavel de retorno da agencia
       vr_nrseqarq    PLS_INTEGER; -- NUmero sequencial do arquivo
       vr_tab_lcm     PAGA0001.typ_tab_lcm_consolidada; -- Tabela de lancamentos para cobranda da tarifa

       -- Job de envio de negativação
       vr_nomdojob VARCHAR2(40) := 'JBCOBRAN_ENVIO_SERASA';

       --Variaveis de controle do programa
       vr_cdcritic    NUMBER:= 0;
       vr_dscritic    VARCHAR2(4000);
       vr_des_erro    VARCHAR2(10);

       -- Variável para armazenar as informações em XML
       vr_clob      CLOB;
       vr_dstexto   VARCHAR2(32700);

       --Variaveis de Excecao
       vr_exc_saida  EXCEPTION;

     BEGIN
             
        -- Executar apenas em dias úteis
        IF trunc(SYSDATE) <> gene0005.fn_valida_dia_util(3, trunc(SYSDATE)) THEN
          RETURN;
        END IF;

        -- Gera log de início de execução
        cecred.pc_log_programa(PR_DSTIPLOG   => 'I'                                
                              ,PR_CDPROGRAMA => vr_nomdojob
                              ,pr_tpexecucao => 2
                              ,PR_IDPRGLOG   => vr_idprglog);

        -- Busca diretorio que o arquivo devera ser gerado
        vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdacesso => 'DIR_ENVIO_SERASA');

        -- Loop sobre as cooperativas
        FOR rw_crapcop IN cr_crapcop LOOP
          
          -- Abre o cursor de data
          OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper); -- Cooperativa Cecred
          FETCH btch0001.cr_crapdat INTO rw_crapdat;
          CLOSE btch0001.cr_crapdat;

          -- Busca a quantidade de dias de vencimento
          OPEN cr_param(rw_crapcop.cdcooper);
          FETCH cr_param INTO rw_param;
          CLOSE cr_param;

          -- Altera a situacao para pendente de envio de todos os boletos vencidos e que possuem 
          -- quantidade de dias superior ao igual a data atual
          BEGIN
            UPDATE crapcob a
               SET inserasa = 1 -- Pendente de envio
             WHERE cdcooper = rw_crapcop.cdcooper
               AND qtdianeg >  0 -- SOmente os que possuem quantidade de dias para negativacao
               AND incobran = 0 -- Pendente
               AND flserasa = 1 -- Possui permissao de negativacao na Serasa
               AND inserasa = 0 -- Nao enviado ao Serasa ainda
               AND dtvencto + qtdianeg < rw_crapdat.dtmvtolt
               AND NOT EXISTS (SELECT 1                -- Se existir esta tabela eh que ja foi enviado uma vez
                                 FROM tbcobran_his_neg_serasa b -- Neste caso nao deve enviar novamente
                                WHERE b.cdcooper = a.cdcooper
                                  AND b.nrdconta = a.nrdconta
                                  AND b.cdbandoc = a.cdbandoc
                                  AND b.nrdctabb = a.nrdctabb
                                  AND b.nrcnvcob = a.nrcnvcob
                                  AND b.nrdocmto = a.nrdocmto);
          EXCEPTION
            WHEN OTHERS THEN 
              vr_dscritic := 'Erro ao atualizar CRAPCOB (inserasa): '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          -- Calcula o digito da agencia
          vr_nrdigage := rw_crapcop.cdagectl * 10;
          vr_lixo := gene0005.fn_calc_digito(pr_nrcalcul => vr_nrdigage);
          vr_nrdigage := vr_nrdigage - (rw_crapcop.cdagectl * 10);
            
          -- Abre o CLOB do arquivo
          dbms_lob.createtemporary(vr_clob, TRUE);
          dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
          
          -- Obtem o sequencial do arquivo
          vr_nrseqarq := fn_sequence(pr_nmtabela => 'CRAPCOB', pr_nmdcampo => 'NRSEQARQ',pr_dsdchave => rw_crapcop.cdcooper);

          -- Inicializa variavel de sequencial do arquivo
          vr_nrseqblt := 1;

          -- Criar HEADER do arquivo
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_dstexto
                                 ,pr_texto_novo     => '0'                                     || --> Código do registro = '0' (zero)
                                                       lPad(rw_crapcop.nrdocnpj,9,'0')         || --> Número do CNPJ
                                                       to_char(rw_crapdat.dtmvtolt,'yyyymmdd') || --> Data do movimento (AAAAMMDD)
                                                       lPad(rw_crapcop.nrdddtel,4,'0')         || --> Número de DDD do telefone
                                                       lPad(rw_crapcop.nrtelvoz,8,'0')         || --> Número do telefone
                                                       RPad(' ',4,' ')                         || --> Número de ramal 
                                                       RPad('Ailos Cobrancas',70,' ')         || --> Nome do contato da Instituição Conveniada   
                                                       RPad('SERASA-CONVEM07',15,' ')          || --> Identificação do arquivo fixo 'SERASA-CONVEM07'
                                                       LPAD(vr_nrseqarq,6,'0')                 || --> Número da remessa do arquivo seqüencial
                                                       'E'                                     || --> Código de envio de arquivo  = 'E' (ENTRADA) e 'R' (RETORNO)
                                                       RPad(' ',4,' ')                         || --> Diferencial de remessa
                                                       RPad(' ',40,' ')                        || --> Deixar em branco 
                                                       '002'                                   || --> Versão do Layout – Constante '002'
                                                       RPad(' ',660,' ')                       || --> Deixar em branco 
                                                       RPad(' ',60,' ')                        || --> Código de erros  
                                                       LPAD(vr_nrseqblt,7,'0')                 || --> Seqüência do registro no arquivo igual a 0000001
                                                       chr(10));
                 
          -- Atualiza Sequencia do registro no arquivo                                             
          vr_nrseqblt := (vr_nrseqblt + 1);
          
          -- Limpa a variavel
          vr_dsserasa := NULL;  

          -- Loop sobre os boletos pendentes
          FOR rw_crapcob IN cr_crapcob(rw_crapcop.cdcooper) LOOP 
            
            -- Consulta campos da Linha Digitavel
            cobr0005.pc_buscar_titulo_cobranca(pr_cdcooper => rw_crapcob.cdcooper
                                              ,pr_nrdconta => rw_crapcob.nrdconta
                                              ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                              ,pr_nrdocmto => rw_crapcob.nrdocmto
                                              ,pr_incobran => rw_crapcob.incobran
                                              ,pr_cdoperad => '1'
                                              ,pr_nriniseq => 0
                                              ,pr_nrregist => 1
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic
                                              ,pr_tab_cob => vr_tab_cob);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_Exc_saida;
            END IF;
            -- Fim - Consulta campos da Linha Digitavel

            -- Conforme conversado com Victor, para a instrucao de vencimento, deve-se colocar a impressao da 2a. via
            vr_tab_cob(1).dsdinst2 := 'Apos o vencimento ou 2a. via, acesse '||rw_crapcop.dsendweb;
           
            -- Abre o Cursor Dados do Credor
            OPEN cr_crapjur(rw_crapcob.cdcooper
                           ,rw_crapcob.nrdconta);                 
            FETCH cr_crapjur INTO rw_crapjur;
            CLOSE cr_crapjur;
            
            -- Identifica tipo de acao
            IF (rw_crapcob.inserasa = 1) THEN
              vr_dsserasa := 'I';
            ELSE
              vr_dsserasa := 'E';
            END IF;
            
            -- Abre o Cursor Dados do Devedor
            OPEN cr_crapsab(rw_crapcob.cdcooper
                           ,rw_crapcob.nrdconta
                           ,rw_crapcob.nrinssac);                 
            FETCH cr_crapsab INTO rw_crapsab;
            CLOSE cr_crapsab;
            
            -- Tipo de pessoa do Devedor
            IF (rw_crapsab.cdtpinsc = 1) THEN
              vr_dstpinsc := 'F'; -- Fisica
              vr_nrtpinsc := '2'; -- CPF
            ELSE
              vr_dstpinsc := 'J'; -- Juridica
              vr_nrtpinsc := '1'; -- CNPJ
            END IF;
            
            -- Especie do Titulo
            CASE rw_crapcob.cddespec
              WHEN 1 THEN
                vr_dsdespec := 'DM';
              WHEN 2 THEN
                vr_dsdespec := 'DS';
              WHEN 3 THEN
                vr_dsdespec := 'NP';
              WHEN 4 THEN
                vr_dsdespec := 'DV';
              WHEN 5 THEN
                vr_dsdespec := 'DV';
              WHEN 6 THEN 
                vr_dsdespec := 'DM';
              ELSE 
                vr_dsdespec := 'DM';          
            END CASE;


            -- Calcula a data de vencimento 
            vr_dtvencto := gene0005.fn_valida_dia_util(pr_cdcooper => rw_crapcop.cdcooper,
                                                       pr_dtmvtolt => rw_crapdat.dtmvtolt + rw_param.qtdias_vencimento );
                                             
            -- Busca valor de multa
            vr_vlfatura := rw_crapcob.vltitulo;
           
            -- Abatimento deve ser calculado antes dos juros/multa 
            IF rw_crapcob.vlabatim > 0 THEN
              vr_vlfatura := vr_vlfatura - rw_crapcob.vlabatim;
            END IF;
           
            /* MULTA PARA ATRASO */
            vr_vlrmulta := 0;
            IF rw_crapcob.tpdmulta = 1  THEN /* Valor */
              vr_vlrmulta := rw_crapcob.vlrmulta;
            ELSIF rw_crapcob.tpdmulta = 2  THEN /* % de multa */
              vr_vlrmulta := (rw_crapcob.vlrmulta * vr_vlfatura) / 100;
            END IF;

            /* MORA PARA ATRASO */
            vr_vlrjuros := 0;
            IF rw_crapcob.tpjurmor = 1  THEN /* dias */
              vr_vlrjuros := rw_crapcob.vljurdia * 
                                      (vr_dtvencto - rw_crapcob.dtvencto);
            ELSIF rw_crapcob.tpjurmor = 2  THEN /* mes */
              vr_vlrjuros := (vr_vlfatura * 
                                      ((rw_crapcob.vljurdia / 100) / 30) * 
                                      (vr_dtvencto - rw_crapcob.dtvencto));
            END IF;

            -- Busca o codigo de barras
            -- Obs.: calcular codigo de barras com o valor atualizado
            cobr0005.pc_calc_codigo_barras(pr_dtvencto => vr_dtvencto,
                                           pr_cdbandoc => rw_crapcob.cdbandoc,
                                           pr_vltitulo => rw_crapcob.vltitulo+vr_vlrjuros+vr_vlrmulta,
                                           pr_nrcnvcob => rw_crapcob.nrcnvcob,
                                           pr_nrcnvceb => 0, -- Utilizado somente para convenios do BB
                                           pr_nrdconta => to_number(SUBSTR(rw_crapcob.nrnosnum,1,8)),
                                           pr_nrdocmto => to_number(SUBSTR(rw_crapcob.nrnosnum,9,9)),
                                           pr_cdcartei => rw_crapcob.cdcartei,
                                           pr_cdbarras => vr_cdbarras);

            -- Busca a linha digitavel
            cobr0005.pc_calc_linha_digitavel(pr_cdbarras => vr_cdbarras,
                                             pr_lindigit => vr_lindigit);
                   
            -- Cria texto do arquivo
            -- Dados da Anotação - Registro "1"
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_dstexto
                                   ,pr_texto_novo     => '1'                              || --> Código do registro = '1'
                                                         vr_dsserasa                      || --> Código da operação
                                                         RPad(rw_crapcop.nrdigito,6,' ')  || --> Filial e Dígito da Instituição Informante     
                                                         LPad(rw_crapcop.nrdocnpj_completo,15,'0') || --> CNPJ da Instituição Conveniada (Base + Filial + Digito)
                                                         'J'                              || --> Tipo de Pessoa do Credor
                                                         '1'                              || --> Tipo do primeiro documento do Credor
                                                         LPad(rw_crapjur.nrcpfcgc,15,'0') || --> Documento do Credor 
                                                         RPad(rw_crapjur.nmextttl,70,' ') || --> Razão Social do Credor    
                                                         RPad(rw_crapjur.nmfansia,25,' ') || --> Nome Fantasia do Credor     
                                                         RPad(rw_crapjur.dsendere,45,' ') || --> Endereço do Credor
                                                         RPad(rw_crapjur.nmbairro,20,' ') || --> Bairro do Credor
                                                         RPad(rw_crapjur.nmcidade,25,' ') || --> Município do Credor 
                                                         RPad(rw_crapjur.cdufende,2,' ')  || --> Sigla Unidade Federativa do Credor      
                                                         LPad(rw_crapjur.nrcepend,8,'0')  || --> Código de endereçamento postal
                                                         LPad(rw_crapjur.nrdddtfc,4,'0')  || --> DDD do Telefone do Credor
                                                         LPad(rw_crapjur.nrtelefo,9,'0')  || --> Telefone do Credor
                                                         RPad(rw_crapjur.nrdramal,4,' ')  || --> Número de ramal do telefone do Credor 
                                                         vr_dstpinsc                      || --> Tipo de pessoa do Devedor (F - Fisica / J - Juridica)
                                                         vr_nrtpinsc                      || --> Tipo do primeiro documento do Devedor ( 1 – CNPJ ou 2 - CNPJ) 
                                                         LPad(rw_crapsab.nrinssac,15,'0') || --> Documento do Devedor (CPF ou CNPJ)
                                                         RPad(' ',1,' ')                  || --> Tipo do segundo documento do Devedor
                                                         RPad(' ',15,' ')                 || --> Segundo Documento do Devedor
                                                         RPad(' ',2,' ')                  || --> UF do Segundo Documento do Devedor
                                                         RPad(rw_crapsab.nmdsacad,70,' ') || --> Nome do Devedor
                                                         RPad(rw_crapsab.dsendsac,45,' ') || --> Endereço do Devedor
                                                         RPad(rw_crapsab.complend,25,' ') || --> Complemento do Endereço do Devedor
                                                         RPad(rw_crapsab.nmbaisac,20,' ') || --> Bairro do Devedor
                                                         RPad(rw_crapsab.nmcidsac,25,' ') || --> Município do Devedor
                                                         RPad(rw_crapsab.cdufsaca,2,' ')  || --> Sigla Unidade Federativa do Devedor
                                                         LPad(rw_crapsab.nrcepsac,8,'0')  || --> CEP do Devedor
                                                         RPad(' ',4,' ')                  || --> DDD do Telefone do Devedor
                                                         RPad(' ',9,' ')                  || --> Telefone do Devedor
                                                         RPad(' ',70,' ')                 || --> Nome do Pai do Devedor
                                                         RPad(' ',70,' ')                 || --> Nome da Mãe do Devedor
                                                         RPad(' ',8,' ')                  || --> Data de Nascimento do Devedor
                                                         RPad(nvl(rw_crapcob.nrnosnum,' '),15,' ') || --> Nosso número – da Instituição Conveniada
                                                         RPad(vr_dsdespec,3,' ')          || --> Espécie do Titulo
                                                         RPad(rw_crapjur.nmcidade,40,' ') || -- Cidade que Originou a Anotação
                                                         RPad(rw_crapjur.cdufende,2,' ')  || --> UF que Originou a Anotação
                                                         
                                                         RPad(nvl(to_char(rw_crapcob.nrdocmto),' '),16,' ') || --> Número do titulo ou contrato
                                                         RPad(rw_crapcob.dtdocmto,8,' ')  || --> Data da Emissão do Título 
                                                         to_char(rw_crapcob.dtvencto,'YYYYMMDD')  || --> Data de Vencimento do Título
                                                         '001'                            || --> Tipo de Moeda ( 001 – Real )
                                                         LPad(rw_crapcob.vltitulo*100,15,'0') || --> Valor do Titulo -  2 decimais
                                                         RPad(' ',15,' ')                 || --> Saldo do Contrato 
                                                         RPad(' ',1,' ')                  || --> Tipo de Endosso do Titulo
                                                         RPad(' ',1,' ')                  || --> Informação sobre Aceite 
                                                         '1'                              || --> Número de Controle(s) do(s) Devedor(es)
                                                         RPad(' ',1,' ')                  || --> Tipo de Anotação 
                                                         RPad(rw_crapcob.nrcnvcob,10,' ') || --> Uso Reservado da Instituição Conveniada (na inclusão)
                                                         RPad(nvl(to_char(rw_crapcob.nrdconta),' '),10,' ') || --> Uso Reservado da Instituição Conveniada (na inclusão)
                                                         RPad(' ',2,' ')                  || --> Motivo de Baixa
                                                         'B'                              || --> Indicativo do Tipo de Comunicado ao Devedor
                                                         RPad(' ',1,' ')                  || --> Indicador de Melhor Endereço
                                                         RPad(' ',1,' ')                  || --> Indicador de SMS
                                                         RPad(' ',4,' ')                  || --> Deixar em branco
                                                         vr_dstpinsc                      || --> Tipo de pessoa do Principal da Dívida
                                                         vr_nrtpinsc                      || --> Tipo do documento do Principal da Dívida
                                                         LPad(rw_crapsab.nrinssac,15,'0') || --> Documento do Principal da Dívida
                                                         RPad(' ',15,' ')                 || --> Deixar em branco
                                                         RPad(' ',60,' ')                 || --> Códigos de erros
                                                         LPAD(vr_nrseqblt,7,'0')          || --> Seqüência do registro no arquivo 
                                                         chr(10));
                                                         
            -- Atualiza Sequencia do registro no arquivo                                             
            vr_nrseqblt := (vr_nrseqblt + 1);
                                                         
            -- Cria texto do arquivo
            -- Boleto Bancário – Registro "2"
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_dstexto
                                   ,pr_texto_novo     => '2'                              || --> Código do registro = '2'
                                                         lpad(rw_crapcop.cdbcoctl,3,'0')  || --> Código do Banco
                                                         '1'                              || --> Digito do Banco
                                                         RPad(rw_crapcop.nmrescop,15,' ') || --> Nome do Banco
                                                         substr(vr_lindigit,1,5)          || --> Primeiro campo da Linha Digitavel
                                                         substr(vr_lindigit,7,5)          || --> Segundo campo da Linha Digitavel
                                                         substr(vr_lindigit,13,5)         || --> Terceiro campo da Linha Digitavel
                                                         substr(vr_lindigit,19,6)         || --> Quarto campo da Linha Digitavel
                                                         substr(vr_lindigit,26,5)         || --> Quinto campo da Linha Digitavel
                                                         substr(vr_lindigit,32,6)         || --> Sexto campo da Linha Digitavel
                                                         substr(vr_lindigit,39,1)         || --> Sétimo campo da Linha Digitavel
                                                         substr(vr_lindigit,41,14)        || --> Oitavo campo da Linha Digitavel
                                                         RPad(vr_dstxtpgt,70,' ')         || --> Texto do Local de Pagamento
                                                         RPad(' ',70,' ')                 || --> Deixar em Branco
                                                         to_char(vr_dtvencto,'YYYYMMDD')  || --> Data do vencimento do boleto – AAAAMMDD  ou Branco(caso queira a expressão 'CONTRA APRESENTACAO'                
                                                         'J'                              || --> Tipo de pessoa do cedente; Física (F) ou Jurídica( J )
                                                         '1'                              || --> Tipo do primeiro docto. do cedente: 1-CNPJ ou 2-CPF
                                                         LPad(rw_crapjur.nrcpfcgc,15,'0') || --> Documento do cedente 
                                                         RPad(rw_crapjur.nmextttl,40,' ') || --> Nome do cedente do título.
                                                         rpad(lpad(rw_crapcop.cdagectl,4,'0')||'-'||vr_nrdigage||' '||
                                                              gene0002.fn_mask_conta(rw_crapcob.nrdconta),
                                                              25,' ')                     || --> Código e Digito da Agência + Código e Digito do cedente
                                                         RPad(rw_crapcob.dtdocmto,8,' ')  || --> Data do documento – AAAAMMDD
                                                         RPad(rw_crapcob.dsdoccop,25,' ') || --> Número do documento
                                                         RPad(' ',5,' ')                  || --> Sigla da espécie do documento – exemplo: NF, DP, etc.
                                                         RPad(' ',3,' ')                  || --> Código do aceite do título N ou S
                                                         RPad(' ',17,' ')                 || --> Para uso do banco 
                                                         RPad(' ',3,' ')                  || --> Deixar em branco
                                                         to_char(rw_crapdat.dtmvtolt,'yyyymmdd') || --> Data do Processamento – AAAAMMDD
                                                         RPad(nvl(rw_crapcob.nrnosnum,' '),25,' ') || --> Nosso número
                                                         RPad('01',5,' ')                 || --> Número da Carteira
                                                         RPad('R$',3,' ')                 || --> Espécie de Moeda (R$) 
                                                         RPad(' ',9,' ')                  || --> Quantidade de Moeda 
                                                         RPad(' ',1,' ')                  || --> Qtde de decimais do Valor da Moeda
                                                         RPad(' ',9,' ')                  || --> Valor da Moeda 
                                                         LPad(rw_crapcob.vltitulo*100,15,'0') || --> Valor do boleto (valor a ser pago pelo devedor ) com 2 decimais, sem ponto e virgula                                            
                                                         RPad(' ',15,' ')                 || --> Valor do desconto, caso houver, com 2 decimais, sem ponto e virgula                                                                                 
                                                         RPad(' ',15,' ')                 || --> Valor de outras deduções, caso houver, com 2 decimais, sem ponto e virgula                                           
                                                         LPad((vr_vlrjuros+vr_vlrmulta)
                                                                *100,15,'0')              || --> Valor da mora ou multa, caso houver, com 2 decimais, sem ponto e virgula                                           
                                                         RPad(' ',15,' ')                 || --> Valor de outros acréscimos, caso houver, com 2 decimais, sem ponto e virgula                                           
                                                         LPad((rw_crapcob.vltitulo+vr_vlrjuros+vr_vlrmulta)
                                                                *100,15,'0')              || --> Valor total a ser cobrado, com 2 decimais, sem ponto e virgula.                                                              
                                                         RPad(' ',1,' ')                  || --> Tipo de pessoa do sacador; Física (F) ou Jurídica (J )    
                                                         RPad(' ',1,' ')                  || --> Tipo do primeiro docto. do sacador: 1-CNPJ ou 2-CPF   
                                                         RPad(' ',15,' ')                 || --> Documento do sacador: 
                                                         RPad(' ',50,' ')                 || --> Nome do Sacador / Avalista
                                                         RPad(' ',318,' ')                || --> Deixar em branco 
                                                         LPAD(vr_nrseqblt,7,'0')          || --> Seqüência do registro no arquivo
                                                         chr(10));

            -- Atualiza Sequencia do registro no arquivo
            vr_nrseqblt := (vr_nrseqblt + 1);
            
            -- Cria texto do arquivo
            -- Boleto Bancário – Registro "3"
            gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                   ,pr_texto_completo => vr_dstexto
                                   ,pr_texto_novo     => '3'                              || --> Código do registro = '3'
                                                         RPad(nvl(vr_tab_cob(1).dsdinstr,' '),70,' ')|| --> Linha de Instrução – 1
                                                         RPad(nvl(vr_tab_cob(1).dsdinst1,' '),70,' ')|| --> Linha de Instrução – 2
                                                         RPad(nvl(vr_tab_cob(1).dsdinst2,' '),70,' ')|| --> Linha de Instrução – 3
                                                         RPad(nvl(vr_tab_cob(1).dsinfor1,' '),70,' ')|| --> Linha de Instrução – 4
                                                         RPad(nvl(vr_tab_cob(1).dsinfor2,' '),70,' ')|| --> Linha de Instrução – 5
                                                         RPad(nvl(vr_tab_cob(1).dsinfor3,' '),70,' ')|| --> Linha de Instrução – 6
                                                         RPad(nvl(vr_tab_cob(1).dsinfor4,' '),70,' ')|| --> Linha de Instrução – 7
                                                         RPad(nvl(vr_tab_cob(1).dsinfor5,' '),70,' ')|| --> Linha de Instrução – 8
                                                         RPad(' ',332,' ')                || --> Deixar em branco 
                                                         LPAD(vr_nrseqblt,7,'0')          || --> Seqüência do registro no arquivo
                                                         chr(10));

            -- Atualiza Sequencia do registro no arquivo
            vr_nrseqblt := (vr_nrseqblt + 1);
            
            -- Atualiza a situacao do boleto para enviado
            pc_atualiza_situacao(pr_rowid    => rw_crapcob.rowid,
                                 pr_cdcooper => rw_crapcop.cdcooper,
                                 pr_cdbandoc => rw_crapcob.cdbandoc,
                                 pr_nrdctabb => rw_crapcob.nrdctabb,
                                 pr_nrcnvcob => rw_crapcob.nrcnvcob,
                                 pr_nrdconta => rw_crapcob.nrdconta,
                                 pr_nrdocmto => rw_crapcob.nrdocmto,
                                 pr_inserasa => rw_crapcob.inserasa,
                                 pr_dscritic => vr_dscritic);
            
          END LOOP;

          -- Cria TRAIL do arquivo
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_dstexto
                                 ,pr_texto_novo     => '9'                              || --> Código do registro = '9'
                                                       RPad(' ',892,' ')                || --> Deixar em branco 
                                                       LPAD(vr_nrseqblt,7,'0')             --> Seqüência do registro no arquivo
                                 ,pr_fecha_xml      => TRUE);


          -- Se possui algum boleto para enviar
          -- Vai enviar arquivo somente se possuir dados
          IF vr_dsserasa IS NOT NULL THEN
            -- Cria o nome do arquivo
            vr_nmarquiv := 'NDM.ND'||rw_crapcop.cdcliser ||'.CVDEV.D'||
                             to_char(SYSDATE,'YYMMDD')||'.H'||to_char(SYSDATE,'HH24MISS');
            -- Converte o CLOB para arquivo
            gene0002.pc_clob_para_arquivo(pr_clob => vr_clob
                                         ,pr_caminho => vr_dsdireto
                                         ,pr_arquivo => 'temporario.txt'
                                         ,pr_des_erro => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              -- Decrementar a sequence do arquivo e ir para a próxima cooperativa
              vr_nrseqarq := fn_sequence(pr_nmtabela => 'CRAPCOB',
                                         pr_nmdcampo => 'NRSEQARQ',
                                         pr_dsdchave => rw_crapcop.cdcooper,
                                         pr_flgdecre => 'S');

              -- Libera a memoria do CLOB
              dbms_lob.close(vr_clob);

              -- Logar critica encontrada
              cecred.pc_log_programa(PR_DSTIPLOG   => 'E'
                                    ,PR_CDPROGRAMA => vr_nomdojob
                                    ,pr_tpocorrencia => 1
                                    ,pr_dsmensagem => 'Coop: ' || rw_crapcop.cdcooper || ' - ' || vr_dscritic
                                    ,PR_IDPRGLOG   => vr_idprglog);

              -- Ir para a próxima cooperativa
              vr_dscritic := '';
              ROLLBACK;              
              continue;
            END IF;
                       
            -- Converte o arquivo para o formato ANSI
            gene0001.pc_OScommand_Shell(pr_des_comando => 'iconv -f utf-8 -t ISO8859-1 '||vr_dsdireto||'/temporario.txt'||
                                                            ' > '||vr_dsdireto||'/'||vr_nmarquiv);

            -- Exclui o arquivo temporario
            gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_dsdireto||'/temporario.txt');
          ELSE
            -- Decrementa a sequence do arquivo
            vr_nrseqarq := fn_sequence(pr_nmtabela => 'CRAPCOB', pr_nmdcampo => 'NRSEQARQ',pr_dsdchave => rw_crapcop.cdcooper, pr_flgdecre => 'S');            
          END IF;

          -- Loop sobre os boletos para negativar apos a quantidade de dias de recebimento da Serasa
          FOR rw_crapcob_2 IN cr_crapcob_2(rw_crapcop.cdcooper, rw_crapdat.dtmvtolt) LOOP
            -- Atualiza a situacao para negativado
            BEGIN
              UPDATE crapcob
                 SET inserasa = 5
               WHERE ROWID = rw_crapcob_2.rowid;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar a situacao da CRAPCOB: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          
            -- Inserir log de envio da negativacao
            paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob_2.rowid,
                                          pr_cdoperad => '1',
                                          pr_dtmvtolt => trunc(SYSDATE), -- Rotina nao utiliza esta data
                                          pr_dsmensag => 'Boleto negativado - Serasa',
                                          pr_des_erro => vr_des_erro,
                                          pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            
            --Prepara retorno cooperado
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => rw_crapcob_2.rowid --ROWID da cobranca
                                               ,pr_cdocorre => 93 -- Negativacao Serasa
                                               ,pr_cdmotivo => 'S3' -- Negativado na Serasa
                                               ,pr_vltarifa => 0
                                               ,pr_cdbcoctl => 0
                                               ,pr_cdagectl => 0
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --Data Movimento
                                               ,pr_cdoperad => '1' --Codigo Operador
                                               ,pr_nrremass => 0
                                               ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                               ,pr_dscritic => vr_dscritic); --Descricao Critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

            -- Limpa a tabela de lancamentos
            vr_tab_lcm.delete;
            
            -- Efetua a cobranca da tarifa
            PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => rw_crapcob_2.rowid --ROWID da cobranca
                                                ,pr_cdocorre => 93          --Codigo Ocorrencia
                                                ,pr_tplancto => 'T'         --Tipo Lancamento
                                                ,pr_vltarifa => 0           --Valor Tarifa
                                                ,pr_cdhistor => 0           --Codigo Historico
                                                ,pr_cdmotivo => 'S3'        --Codigo motivo
                                                ,pr_tab_lcm_consolidada => vr_tab_lcm --Tabela de Lancamentos
                                                ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;

            IF vr_tab_lcm.exists(vr_tab_lcm.first) THEN
              -- Efetua o pagamento da tarifa
              PAGA0001.pc_realiza_lancto_cooperado (pr_cdcooper => rw_crapcop.cdcooper --Codigo Cooperativa
                                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento
                                                   ,pr_cdagenci => rw_crapcob_2.cdagenci --Codigo Agencia
                                                   ,pr_cdbccxlt => rw_crapcob_2.cdbccxlt --Codigo banco caixa
                                                   ,pr_nrdolote => rw_crapcob_2.nrdolote --Numero do Lote
                                                   ,pr_cdpesqbb => rw_crapcob_2.nrconven --Codigo Convenio
                                                   ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                                   ,pr_dscritic => vr_dscritic         --Descricao Critica
                                                   ,pr_tab_lcm_consolidada => vr_tab_lcm);        --Tabela Lancamentos
              --Se ocorreu erro
              IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_saida;
            END IF;
            END IF;
            
          END LOOP;

          -- Grava as informacoes dos envios da cooperativa
          COMMIT;

          -- Libera a memoria do CLOB
          dbms_lob.close(vr_clob);

        END LOOP;

      -- Gera log fim do processo
      cecred.pc_log_programa(PR_DSTIPLOG   => 'F'
                            ,PR_CDPROGRAMA => vr_nomdojob
                            ,PR_IDPRGLOG   => vr_idprglog);

     EXCEPTION
       WHEN vr_exc_saida THEN

           -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

         -- Devolvemos código e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
 
         -- Logar fim de execução sem sucesso
         cecred.pc_log_programa(PR_DSTIPLOG   => 'E'
                               ,PR_CDPROGRAMA => vr_nomdojob
                               ,pr_tpocorrencia => 1
                               ,pr_dsmensagem => vr_dscritic
                               ,PR_IDPRGLOG   => vr_idprglog);
         -- Logar fim de execução sem sucesso
         cecred.pc_log_programa(PR_DSTIPLOG   => 'F'
                               ,PR_CDPROGRAMA => vr_nomdojob
                               ,pr_flgsucesso => 0
                               ,PR_IDPRGLOG   => vr_idprglog);
         
         -- Efetuar rollback
         ROLLBACK;
       WHEN OTHERS THEN
         
         cecred.pc_internal_exception(3);
       
         -- Efetuar retorno do erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := SQLERRM;
         -- Efetuar rollback
         ROLLBACK;
     END;
   END PC_CRPS330;
/
