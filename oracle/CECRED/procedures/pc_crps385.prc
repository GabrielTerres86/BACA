CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps385 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta IN PLS_INTEGER             --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps385 (Fontes/crps385.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autora  : Mirtes
       Data    : Marco/2004.                        Ultima atualizacao: 25/10/2017

       Dados referentes ao programa:

       Frequencia: Diario (Batch).
       Objetivo  : Atender a solicitacao 092
                   Gerar arquivos de arrecadacao, conforme convenios cadastrados
                   Emite relatorio 342.
       Alteracoes : Sequenciar pelo numero do convenio. Arquivos via e_mail ,
                    utilizar diretorio micros(Mirtes)

                    12/01/2005 - Tratamento SAMAE Timbo (Julio)

                    19/01/2005 - Tratamento para IPTU Indaial (Julio)

                    28/01/2005 - Tratamento para SAMAE GASPAR/CECRED -> 634 (Julio)

                    02/05/2005 - Ordenar por PAC e CAIXA (Evandro).

                    30/05/2005 - Convenio Aguas Itapema -> 456 (Julio)

                    06/06/2005 - Preparacao para unificacao de arquivos (Julio)

                    15/08/2005 - Mandar relatorio por e-mail para Prefeitura
                                 Indaial. Tratamento SAMAE Brusque -> 615 (Julio).

                    23/09/2005 - Modificado FIND FIRST para FIND na tabela
                                 crapcop.cdcooper = glb_cdcooper (Diego).

                    12/01/2006 - Tratamento para P.M.Itajai -> 659 (Julio)

                    16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

                    09/08/2006 - Tratamento para P.M.Pomerode -> 663 (Julio)

                    26/10/2006 - Incluir data do movimento nos e-mails (David).

                    23/11/2006 - Acertar envio de email pela BO b1wgen0011 (David).

                    27/02/2007 - Apos alteracao do envio de e-mail, estava enviando
                                 relatorio em branco para a Prefeitura Intaial (18)
                                 (Julio).

                    01/06/2007 - Incluido envio de arquivo para Accestage (Elton).

                    05/06/2007 - Altera numero do convenio no arquivo de caixa da
                                 DAE NAVEGANTES para ser diferente do numero de
                                 convenio do arquivo de debito automatico (Elton).

                    23/08/2007 - Tratamento de tarifas para internet(Guilherme)
                               - Colocado chamada do fontes/fimprg.p para as saidas
                                 com RETURN (Evandro).

                    25/09/2007 - Incluido coluna contendo o PAC onde foi feito o
                                 pagamento. Demonstrado no relatorio os totais
                                 dos pagamentos feitos pela internet (Elton).

                    28/11/2007 - Alterado numero do convenio do arquivo de caixa da
                                 SEMASA Itajai para ser diferente do numero de
                                 convenio do arquivo de debito automatico (Elton).

                    30/11/2007 - Alterado numero do convenio do arquivo de caixa da
                                 Aguas de Joinville para ser diferente do numero de
                                 convenio do arquivo de debito automatico (Elton).

                    22/01/2008 - IPTU Blumenau passa a ter o mesmo tratamento dos
                                 outros convenio (Elton).

                    18/03/2008 - Alterado envio de email para BO b1wgen0011
                                 (Sidnei - Precise)

                    04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                                 arquivo (Martin).

                    21/12/2009 - Faturas da CASAN -> 348 pagas no caixa serao
                                 consideradas como pagas na internet (Elton).

                    02/06/2010 - Alteraçao do campo "pkzip25" para "zipcecred.pl"
                                 (Vitor).

                    11/06/2010 - Incluido tipo de pagamento "2" quando for feito
                                 atraves de TAA e no relatorio incluido o valor das
                                 tarifas referente a TAA (Elton).

                    28/04/2011 - Tratamento para guardar mais um campo de valor
                                 para Foz do Brasil -> 963;
                               - Alterado numero do convenio do arquivo de caixa
                                 da Aguas de Massaranduba para ser diferente do
                                 numero de convenio do arquivo de debito
                                 automatico (Elton).

                    23/01/2012 - Gravar Tipo Controle na GNCVUNI (Guilherme/Supero)

                    07/03/2012 - Ajuste na criacao do registro "G".Incluido conforme
                                 o layout da FEBRABAN os campos G.11, G12
                                 (Adriano).

                    18/05/2012 - Mostra somente 20 caracteres no relatorio
                                 crrl342.lst no campo sequencial quando valor tiver
                                 mais de 20 caracteres (Elton).

                    22/06/2012 - Substituido gncoper por crapcop (Tiago).

                    02/07/2012 - Alterado nomeclatura do relatório gerado incluindo
                                 código do convenio (Guilherme Maba).

                    30/07/2012 - Ajuste do format no campo nmrescop (David Kruger).

                    18/09/2012 - Tratamento para codigo febraban da Aguas de
                                 Itapocoroy (Elton).

                    31/10/2012 - Modificacao na agencia arrecadadora e na
                                 autenticacao do arquivo de arrecadacao (Elton).

                    16/08/2013 - Nova forma de chamar as agencias, de PAC agora
                                 a escrita será PA (André Euzébio - Supero).

                    12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                                 (Reinert)

                    22/01/2014 - Incluir VALIDATE gncvuni, gncontr (Lucas R.)

                    26/03/2014 - Conversão Progress >> PLSQL (Edison-AMcom).
                    
                    07/05/2014 - Ajuste para buscar novamente o nrseqcxa e lockar o registro
                                 para que outra cooperativa não gere arquivo com o mesmo sequencial (Odirlei-AMcom).
                                 
                    20/05/2014 - Substituido texto do header do arquivo
                                 (De: 'ARRECADACAO CAIXA' Para: 'CODIGO DE BARRAS ').
                                 (Chamado 154969) - (Fabricio)

                    23/05/2014 - Ajustado para converter arquivo antes de 
                                 enviar email(pc_envia_email_sem_movimento) (Odirlei-AMcom) 
                                 
                    28/11/2014 - Implementacao Van E-Sales (utilizacao inicial pela Oi).
                                 (Chamado 192004) - (Fabricio)

                    03/06/2015 - Retirar validação para o historico 963 Foz do brasil
                                 (Lucas Ranghetti #292200)                                 
                                 
                    15/06/2015 - Alterar calculo da data de Crédito/Repasse, para calcular
                                 de acordo com a tabela gnconve campo tprepass (Lucas Ranghetti #296615)
                                 
                    29/02/2016 - Alterado lpad do nrautdoc para 9 posicoes - Alteracao emergencial 
                                 (Lucas Ranghetti/Fabricio)
                                 
                    23/06/2016 - P333.1 - Devolução de arquivos com tipo de envio 6 - WebService (Marcos)
                                 
                    25/05/2017 - Ajustar as informações de log de operações (Rodrigo)
                            
                    25/10/2017 - Enviar o cdagectl para todos os convenios no arquivo ao invés de 
                                 mandar a cooperativa mais o PA (Lucas Ranghetti #767689)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS385';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdretorn   NUMBER;
      vr_dsretorn   VARCHAR2(4000);
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nmcidade
              ,cop.cdufdcop
              ,cop.cdcooper
              ,cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- seleciona os convenios da cooperativa
      CURSOR cr_gnconve( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT gnconve.cdcooper
              ,gnconve.nmempres
              ,gnconve.cdhiscxa
              ,gnconve.vltrfnet
              ,gnconve.vltrftaa
              ,gnconve.vltrfcxa
              ,gnconve.flgcvuni
              ,gnconve.cdconven
              ,gnconve.nrseqcxa
              ,gnconve.cddbanco
              ,gnconve.nrcnvfbr
              ,gnconve.nmarqcxa
              ,gnconve.tpdenvio
              ,gnconve.dsendcxa
              ,gnconve.tprepass
              ,crapcop.nmrescop
              ,decode(gnconve.cdhiscxa, 398, 'IPTU', 663, 'IPTU', 'NORMAL') dstipo
              ,gnconve.rowid
        FROM   gnconve
              ,gncvcop
              ,crapcop
        WHERE  gnconve.cdconven = gncvcop.cdconven
        AND    gnconve.cdcooper = crapcop.cdcooper
        AND    gncvcop.cdcooper = pr_cdcooper
        AND    gnconve.flgativo = 1
        AND    gnconve.cdhiscxa > 0 -- Somente convenios arrec.caixa
        ORDER BY gnconve.cdconven;
      rw_gnconve cr_gnconve%ROWTYPE;

      --seleciona as faturas
      CURSOR cr_craplft( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtvencto IN DATE
                        ,pr_dtmvtolt IN DATE
                        ,pr_cdhistor IN craplft.cdhistor%TYPE) IS
        SELECT craplft.dtvencto
              ,craplft.cdagenci
              ,craplft.cdbarras
              ,craplft.vllanmto
              ,craplft.dtmvtolt
              ,craplft.cdbccxlt
              ,craplft.nrdolote
              ,craplft.cdseqfat
              ,craplft.nrseqdig
              ,craplft.nrdigfat
              ,craplft.nrautdoc
              ,craplft.cdhistor
              ,craplft.rowid
        FROM  craplft
        WHERE craplft.cdcooper  = pr_cdcooper
        AND   craplft.dtvencto >= pr_dtvencto
        AND   craplft.dtvencto <= pr_dtmvtolt
        AND   craplft.insitfat  = 1
        AND   craplft.cdhistor  = pr_cdhistor
        ORDER BY craplft.cdcooper
                ,craplft.dtmvtolt
                ,craplft.cdagenci
                ,craplft.cdbccxlt
                ,craplft.nrdolote
                ,craplft.cdseqfat;
      rw_craplft cr_craplft%ROWTYPE;

      --seleciona informacoes do controle de execucoes
      CURSOR cr_gncontr( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdconven IN gnconve.cdconven%TYPE
                        ,pr_dtmvtolt IN DATE) IS
        SELECT gncontr.nrsequen
              ,gncontr.rowid
        FROM   gncontr
        WHERE  gncontr.cdcooper = pr_cdcooper
        AND    gncontr.tpdcontr = 1 -- Arrec.Caixa
        AND    gncontr.cdconven = pr_cdconven
        AND    gncontr.dtmvtolt = pr_dtmvtolt;
      rw_gncontr cr_gncontr%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      TYPE typ_tab_varchar IS VARRAY(2) OF VARCHAR2(100);

      ------------------------------- VARIAVEIS -------------------------------
      vr_vet_nmcidade typ_tab_varchar := typ_tab_varchar('','');
      vr_vet_nmrescop typ_tab_varchar := typ_tab_varchar('','');
      vr_dtproxim     DATE;
      vr_dtanteri     DATE;
      vr_nmempres     VARCHAR2(100);
      vr_flgfirst     BOOLEAN;
      vr_nrseqdig     NUMBER;
      vr_dtproces     DATE;
      vr_tot_vlfatura NUMBER;
      vr_tot_vltarifa NUMBER;
      vr_tot_vlapagar NUMBER;
      vr_tot_qtfatcxa NUMBER;
      vr_tot_vlfatcxa NUMBER;
      vr_tot_vltarcxa NUMBER;
      vr_tot_vlpagcxa NUMBER;
      vr_tot_qtfatint NUMBER;
      vr_tot_vlfatint NUMBER;
      vr_tot_vltarint NUMBER;
      vr_tot_vlpagint NUMBER;
      vr_tot_qtfattaa NUMBER;
      vr_tot_vlfattaa NUMBER;
      vr_tot_vltartaa NUMBER;
      vr_tot_vlpagtaa NUMBER;
      vr_tot_vlfatur2 NUMBER;
      vr_tot_vlorpago NUMBER;
      vr_tot_vltitulo NUMBER;
      vr_nrseqarq     INTEGER;
      vr_nmdbanco     VARCHAR2(100);
      vr_nrdbanco     NUMBER;
      vr_nrconven     VARCHAR2(100);
      vr_nmempcov     VARCHAR2(100);
      vr_nrsequen     VARCHAR2(15);
      vr_nmarqdat     VARCHAR2(100);
      vr_nmarqped     VARCHAR2(100);
      vr_dsattach     VARCHAR2(100);
      vr_nmarqrel     VARCHAR2(100);
      vr_path_arquivo VARCHAR2(500);

      --controle de clob
      vr_des_xml         CLOB;
      vr_des_xml2        CLOB;
      vr_texto_completo  VARCHAR2(32600);
      vr_texto_completo2 VARCHAR2(32600);

      -- variaveis de controle de comandos shell
      vr_comando			VARCHAR2(500);
      vr_typ_saida    VARCHAR2(1000);


      --------------------------- SUBROTINAS INTERNAS --------------------------

      --subrotina para atualizar a sequencia do arquivo cfme o convenio utilizado
      PROCEDURE pc_obtem_atualiza_sequencia( pr_cdconven IN gncontr.cdconven%TYPE
                                            ,pr_dtmvtolt IN DATE) IS
        -- Busca sequencial do convenio atualizado e
        -- deixar registro com lock, para o sequencial não ser utilizado por outra cooperativa
        CURSOR cr_gbconve (pr_rowid rowid) is
          SELECT nrseqcxa
            FROM gnconve
           WHERE gnconve.rowid = pr_rowid
           FOR UPDATE; 
        rw_gbconve cr_gbconve%rowtype;                    
        
      BEGIN
        -- Busca sequencial do convenio atualizado
        OPEN cr_gbconve (pr_rowid => rw_gnconve.rowid); 
        FETCH cr_gbconve INTO rw_gbconve;
        CLOSE cr_gbconve;
        
        -- Verificar arquivo controle - se existir nao somar seq.
        vr_nrseqarq := rw_gbconve.nrseqcxa;

        --se não gera arquivo unificado.
        IF rw_gnconve.flgcvuni = 0 THEN
          --atualizando a sequencia
          BEGIN
            UPDATE gnconve SET nrseqcxa = nrseqcxa + 1
            WHERE  gnconve.rowid = rw_gnconve.rowid
            RETURNING gnconve.nrseqcxa
            INTO      rw_gnconve.nrseqcxa;
          EXCEPTION
            WHEN OTHERS THEN
              --gerando critica
              vr_dscritic := 'Erro ao atualizar a tabela gnconve. '||SQLERRM;
              --abortando a execucao
              RAISE vr_exc_saida;
          END;
        END IF;

        BEGIN
          --adicionando registro no controle de execucoes
          INSERT INTO gncontr( cdcooper
                             ,tpdcontr
                             ,cdconven
                             ,dtmvtolt
                             ,nrsequen
          ) VALUES ( pr_cdcooper
                   ,1
                   ,pr_cdconven
                   ,pr_dtmvtolt
                   ,vr_nrseqarq
          ) RETURNING gncontr.nrsequen
                     ,gncontr.ROWID
            INTO      rw_gncontr.nrsequen
                     ,rw_gncontr.rowid;
        EXCEPTION
         WHEN OTHERS THEN
           --gerando critica
           vr_dscritic := 'Erro ao atualizar a tabela gncontr. '||SQLERRM;
           --abortando a execucao
           RAISE vr_exc_saida;
        END;
        
      END pc_obtem_atualiza_sequencia;

      -- subrotina para gerar o nome dos arquivos
      PROCEDURE pc_nomeia_arquivos IS
      BEGIN
        --controle de execucoes
        OPEN cr_gncontr( pr_cdcooper => pr_cdcooper
                        ,pr_cdconven => rw_gnconve.cdconven
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_gncontr INTO rw_gncontr;
        -- se retornar dados guarda a sequencia
        IF cr_gncontr%FOUND THEN
          --fecha o cursor
          CLOSE cr_gncontr;
          --armazena a sequencia do controle
          vr_nrseqarq := rw_gncontr.nrsequen;
        ELSE
          --fecha o cursor
          CLOSE cr_gncontr;
          --gera um novo registro no controle de execucoes
          pc_obtem_atualiza_sequencia( pr_cdconven => rw_gnconve.cdconven
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        END IF;

        --nome da instituicao bancaria
        vr_nmdbanco := rw_gnconve.nmrescop;
        vr_nrdbanco := rw_gnconve.cddbanco;
        vr_nrconven := rw_gnconve.nrcnvfbr;
        vr_nmempcov := rw_gnconve.nmempres;
        vr_nrsequen := LPAD(vr_nrseqarq,6,'0');

        /* Convenios que exigem numero de convenio diferente para arrecadacao caixa
        e debito automatico */
        CASE rw_gnconve.cdconven
          WHEN 24 THEN vr_nrconven := vr_nrconven||'1';
          WHEN 31 THEN vr_nrconven := to_number(vr_nrconven) + 1000; --DAE NAVEGANTES
          WHEN 4  THEN vr_nrconven := '012941';
          WHEN 33 THEN vr_nrconven := '330'; --Aguas de Joinville
          WHEN 34 THEN vr_nrconven := '340'; --SEMASA Itajai
          WHEN 54 THEN vr_nrconven := '540'; --Aguas de Massaranduba
          WHEN 62 THEN vr_nrconven := '620'; --Aguas de Itapocoroy
          ELSE NULL;
        END CASE;

        --gerando o nome do arquivo
        vr_nmarqdat := TRIM(SUBSTR(rw_gnconve.nmarqcxa,1,4))||
                       TO_CHAR(rw_crapdat.dtmvtolt,'MM') ||
                       TO_CHAR(rw_crapdat.dtmvtolt,'DD')||'.'||
                       SUBSTR(vr_nrsequen,4,3);

        --avalia como deve ser gerado o nome do arquivo e extensao
        IF SUBSTR(rw_gnconve.nmarqcxa,5,2) = 'MM' AND
           SUBSTR(rw_gnconve.nmarqcxa,7,2)  = 'DD' AND
           SUBSTR(rw_gnconve.nmarqcxa,10,3) = 'TXT' THEN

          vr_nmarqdat := TRIM(SUBSTR(rw_gnconve.nmarqcxa,1,4))||
                         TO_CHAR(rw_crapdat.dtmvtolt,'MM') ||
                         TO_CHAR(rw_crapdat.dtmvtolt,'DD')||'.txt';
        END IF;

        --avalia como deve ser gerado o nome do arquivo e extensao
        IF SUBSTR(rw_gnconve.nmarqcxa,5,2)  = 'DD' AND
           SUBSTR(rw_gnconve.nmarqcxa,7,2)  = 'MM' AND
           SUBSTR(rw_gnconve.nmarqcxa,10,3) = 'RET' THEN

          vr_nmarqdat := TRIM(SUBSTR(rw_gnconve.nmarqcxa,1,4))||
                         TO_CHAR(rw_crapdat.dtmvtolt,'DD')||
                         TO_CHAR(rw_crapdat.dtmvtolt,'MM') ||'.ret';
        END IF;

        --avalia como deve ser gerado o nome do arquivo e extensao
        IF SUBSTR(rw_gnconve.nmarqcxa,5,2)  = 'CP' AND   /* Cooperativa */
           SUBSTR(rw_gnconve.nmarqcxa,7,2)  = 'MM' AND
           SUBSTR(rw_gnconve.nmarqcxa,9,2)  = 'DD' AND
           SUBSTR(rw_gnconve.nmarqcxa,12,3) = 'SEQ' THEN

          vr_nmarqdat := TRIM(SUBSTR(rw_gnconve.nmarqcxa,1,4)) ||
                         LPAD(rw_gnconve.cdcooper,2,'0')||
                         TO_CHAR(rw_crapdat.dtmvtolt,'MM') ||
                         TO_CHAR(rw_crapdat.dtmvtolt,'DD')||'.'||
                         SUBSTR(vr_nrsequen,4,3);

        END IF;

        IF SUBSTR(rw_gnconve.nmarqcxa,4,1)  = 'C' AND
           SUBSTR(rw_gnconve.nmarqcxa,5,4)  = 'SEQU' AND
           SUBSTR(rw_gnconve.nmarqcxa,10,3) = 'RET' THEN

          vr_nmarqdat := TRIM(SUBSTR(rw_gnconve.nmarqcxa,1,3))||
                         LPAD(rw_gnconve.cdcooper,1,'0')||
                         SUBSTR(vr_nrsequen,3,4)||'.ret';
        END IF;

        --nome do arquivo que será convertido
        vr_nmarqped := vr_nmarqdat;

      END pc_nomeia_arquivos;

      -- subrotina para transmitir o arquivo
      PROCEDURE pc_transmite_arquivo IS
      BEGIN
        DECLARE
          vr_nexxera VARCHAR2(500);
          vr_esales  VARCHAR2(500);
        BEGIN
          --se tipo de envio é internet
          IF rw_gnconve.tpdenvio = 1 OR rw_gnconve.tpdenvio = 4 THEN   -- Internet
            -- Realizar a conversão do arquivo
            GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                        ,pr_nmarquiv => vr_path_arquivo||'/arq/'||vr_nmarqped
                                        ,pr_nmarqenv => vr_nmarqdat
                                        ,pr_des_erro => vr_dscritic);

            IF vr_dscritic IS NOT NULL THEN
              -- O comando shell executou com erro, gerar log e sair do processo
              vr_dscritic := 'Erro ao converter arquivo '||vr_nmarqped||': '|| vr_dscritic;
              RAISE vr_exc_saida;
            END IF;

            --arquivo que sera anexado
            vr_dsattach := vr_path_arquivo||'/converte/'||vr_nmarqdat;

            IF rw_gnconve.cdhiscxa = 639 THEN -- IPTU Indaial
              -- Realizar a conversão do arquivo
              GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                          ,pr_nmarquiv => vr_path_arquivo||'/rl/'||vr_nmarqrel
                                          ,pr_nmarqenv => vr_nmarqrel
                                          ,pr_des_erro => vr_dscritic);

              IF vr_dscritic IS NOT NULL THEN
                -- O comando shell executou com erro, gerar log e sair do processo
                vr_dscritic := 'Erro ao converter arquivo '||vr_nmarqped||': '|| vr_dscritic;
                RAISE vr_exc_saida;
              END IF;

              --arquivos que serao anexados ao email
              vr_dsattach := vr_dsattach || ';' ||
                             vr_path_arquivo||'/converte/'||vr_nmarqrel;
                             
            END IF;
          END IF;
          --codigo da critica
          vr_cdcritic := 657; -- Intranet - tpdenvio = 1
          
          IF rw_gnconve.tpdenvio = 2 THEN -- E-Sales
            --codigo da critica
            vr_cdcritic := 696;

            vr_esales := nvl(gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIR_ESALES'),'/usr/connect/esales/envia');

            -- Comando para copiar o arquivo para a pasta salvar
            vr_comando:= 'cp '||vr_path_arquivo||'/arq/'||vr_nmarqped||' '||vr_esales||'/'||' 2> /dev/null';

            --Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);

            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
             -- retornando ao programa chamador
             RAISE vr_exc_saida;
            END IF;
          END IF;

          IF rw_gnconve.tpdenvio = 3 THEN -- Nexxera
            --codigo da critica
            vr_cdcritic := 748;

            vr_nexxera := nvl(gene0001.fn_param_sistema('CRED',pr_cdcooper,'DIR_NEXXERA'),'/usr/nexxera/envia');

            -- Comando para copiar o arquivo para a pasta salvar
            vr_comando:= 'cp '||vr_path_arquivo||'/arq/'||vr_nmarqped||' '||vr_nexxera||'/'||' 2> /dev/null';

            --Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);

            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
             -- retornando ao programa chamador
             RAISE vr_exc_saida;
            END IF;
          END IF;

          IF rw_gnconve.tpdenvio = 5 THEN -- Accesstage
            
            vr_cdcritic := 905;            

            -- Comando para copiar o arquivo para a pasta salvar
            vr_comando:= 'cp '||vr_path_arquivo||'/arq/'||vr_nmarqped||' '||vr_path_arquivo||'/salvar/'||' 2> /dev/null';

            --Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);

            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
             -- retornando ao programa chamador
             RAISE vr_exc_saida;
            END IF;

          ELSE
            -- Comando para copiar o arquivo para a pasta salvar
            vr_comando:= 'mv '||vr_path_arquivo||'/arq/'||vr_nmarqped||' '||vr_path_arquivo||'/salvar/'||' 2> /dev/null';

            --Executar o comando no unix
            GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida
                                ,pr_des_saida   => vr_dscritic);

            --Se ocorreu erro dar RAISE
            IF vr_typ_saida = 'ERR' THEN
             vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
             -- retornando ao programa chamador
             RAISE vr_exc_saida;
            END IF;
          END IF;
          
          IF rw_gnconve.tpdenvio = 6 THEN -- WebServices
            --codigo da critica
            vr_cdcritic := 982;
            
            CONV0002.pc_armazena_arquivo_conven (pr_cdconven => rw_gnconve.cdconven
                                                ,pr_dtarquiv => rw_crapdat.dtmvtolt
                                                ,pr_tparquiv => 'G' -- Arquivo Caixa -- 
                                                ,pr_flproces => 0 -- Não retornado ainda
                                                ,pr_dscaminh => vr_path_arquivo || '/salvar/'
                                                ,pr_nmarquiv => vr_nmarqped
                                                ,pr_cdretorn => vr_cdretorn   -- Tratar possível erro no retorno (Quando OK virá 202, qualquer outro código é erro) 
                                                ,pr_dsmsgret => vr_dsretorn); -- Detalhe do erro
          
            IF vr_cdretorn <> 202 THEN
              vr_dscritic:= vr_dsretorn;
              -- retornando ao programa chamador
              RAISE vr_exc_saida;
            END IF;
          
          END IF;

          --descricao da critica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

          -- Internet
          IF rw_gnconve.tpdenvio NOT IN(1,4) THEN
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Mensagem
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || vr_dscritic || ' '
                                                         || vr_nmarqdat || ' -  Arrecadacao Cx. - '
                                                         || rw_gnconve.nmempres);

          ELSE
            --envia e-mail
            gene0003.pc_solicita_email( pr_cdcooper => pr_cdcooper
                                       ,pr_cdprogra => vr_cdprogra
                                       ,pr_des_destino => rw_gnconve.dsendcxa
                                       ,pr_des_assunto => 'ARQUIVO DE ARRECADACAO DA '||
                                                          rw_crapcop.nmrescop ||
                                                          ' REFERENTE A DATA '||
                                                          TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/YYYY')
                                       ,pr_des_corpo => NULL
                                       ,pr_des_anexo => vr_dsattach
                                       ,pr_flg_enviar => 'N'
                                       ,pr_des_erro => vr_dscritic);
            -- Testar erro
            IF vr_dscritic IS NOT NULL THEN
              -- O comando executou com erro, gerar log e sair do processo
              RAISE vr_exc_saida;
            END IF;
          END IF;
        END;
      END pc_transmite_arquivo;

      -- subrotina para atualziar a tabela de gncontr
      PROCEDURE pc_atualiza_controle IS
      BEGIN
        ----
        BEGIN
          ----Atualizar Arquivo de Controle ---
          UPDATE gncontr SET dtcredit = vr_dtproxim
                            ,nmarquiv = vr_nmarqdat
                            ,qtdoctos = vr_nrseqdig
                            ,vldoctos = vr_tot_vlfatura
                            ,vltarifa = vr_tot_vltarifa
                            ,vlapagar = vr_tot_vlapagar
                            ,vldocto2 = vr_tot_vlfatur2
          WHERE  gncontr.ROWID = rw_gncontr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            --gerando a critica
            vr_dscritic := 'Erro ao atualizar a tabela gncontr. '||SQLERRM;
            --abortando a execucao
            RAISE vr_exc_saida;
        END;

      END pc_atualiza_controle;

      --subrotina para enviar e-mail quando nao houver movimento
      PROCEDURE pc_envia_email_sem_movimento IS
      BEGIN
        DECLARE
          vr_nmarqimp VARCHAR2(100);
          --controle de clob
          vr_anexo          CLOB;
          vr_anexo_completo VARCHAR2(32600);
        BEGIN
          -- criar arquivo anexo para email
          vr_nmarqimp := vr_cdprogra || '_ANEXO' || gene0002.fn_busca_time;

          --instanciando o clob
          dbms_lob.createtemporary(vr_anexo, true);
          dbms_lob.open(vr_anexo, dbms_lob.lob_readwrite);

          -- iniciando o arquivo que será enviado
          gene0002.pc_escreve_xml(vr_anexo,
                                  vr_anexo_completo,
                                  'NAO HOUVE ARRECADACAO PARA ESTA DATA '
                                  ||RPAD(TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/YYYY'),17,' ')
                                  ||' NA '
                                  ||RPAD(upper(rw_gnconve.nmrescop),20,' ')||chr(13)
                                  ,TRUE);

          --Criar o arquivo no diretorio especificado
          gene0002.pc_clob_para_arquivo(pr_clob     => vr_anexo
                                       ,pr_caminho  => vr_path_arquivo||'/arq/'
                                       ,pr_arquivo  => vr_nmarqimp
                                       ,pr_des_erro => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_anexo);
          dbms_lob.freetemporary(vr_anexo);

          -- Comando para converter o arquivo 
          vr_comando:= 'ux2dos  '||vr_path_arquivo||'/arq/'||vr_nmarqimp||' > '||vr_path_arquivo||'/converte/'||vr_nmarqimp;

          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            -- retornando ao programa chamador
            RAISE vr_exc_saida;
          END IF;
          
          -- Comando para remover arquivo
          vr_comando:= 'rm  '||vr_path_arquivo||'/arq/'||vr_nmarqimp;

          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
            vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
            -- retornando ao programa chamador
            RAISE vr_exc_saida;
          END IF;

          --envia e-mail
          gene0003.pc_solicita_email( pr_cdcooper => pr_cdcooper
                                     ,pr_cdprogra => vr_cdprogra
                                     ,pr_des_destino => rw_gnconve.dsendcxa
                                     ,pr_des_assunto => 'Arquivo Arrecadacao da  ' ||
                                                         rw_gnconve.nmempres ||' '
                                     ,pr_des_corpo => NULL
                                     ,pr_des_anexo => vr_path_arquivo||'/converte/'||vr_nmarqimp
                                     ,pr_flg_enviar => 'N'
                                     ,pr_des_erro => vr_dscritic);
          -- Testar erro
          IF vr_dscritic IS NOT NULL THEN
            -- O comando executou com erro, gerar log e sair do processo
            RAISE vr_exc_saida;
          END IF;

          -- Comando para copiar o arquivo para a pasta salvar
          vr_comando:= 'rm '||vr_path_arquivo||'/arq/'||vr_nmarqimp||' 2> /dev/null';

          --Executar o comando no unix
          GENE0001.pc_OScommand(pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
           -- retornando ao programa chamador
           RAISE vr_exc_saida;
          END IF;

        END;
      END pc_envia_email_sem_movimento;

      --subrotina para gerar os relatorios
      PROCEDURE pc_efetua_geracao_arquivos IS
      BEGIN
        DECLARE
          vr_vltarifa     NUMBER;
          vr_vltitulo     NUMBER;
          vr_cdpeslft     VARCHAR2(100);
          vr_cdseqfat     NUMBER;
          vr_cdcoppac     VARCHAR2(100);
          vr_nrautdoc     VARCHAR2(100);
          vr_tipopagto    CHAR(1);
          vr_dslinreg     VARCHAR2(500);
          vr_tot_qtapagar INTEGER;
          vr_gerar        CHAR(1) := 'N';
        BEGIN
          --prefeitura de Indaial
          -- gera o arquivo fisico para converter, zipar e enviar por e-mail
          IF rw_gnconve.cdhiscxa = 639 THEN
            vr_gerar := 'S';
          END IF;

          --verifica se possui faturas
          OPEN cr_craplft ( pr_cdcooper => pr_cdcooper
                           ,pr_dtvencto => vr_dtproces
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_cdhistor => rw_gnconve.cdhiscxa);
          LOOP
            --carrega o registro no rowtype
            FETCH cr_craplft INTO rw_craplft;
            --sai do loop quando encontrar o ultimo registro
            EXIT WHEN cr_craplft%NOTFOUND;

            --busca a tarifa conforme o codigo da agencia
            IF rw_craplft.cdagenci = 90 THEN      /** Internet **/
              vr_vltarifa := rw_gnconve.vltrfnet;
            ELSIF rw_craplft.cdagenci = 91 THEN   /** TAA **/
              vr_vltarifa := rw_gnconve.vltrftaa;
            ELSE
              vr_vltarifa := rw_gnconve.vltrfcxa; /** Caixa **/
            END IF;

            --se eh o primeiro registro do convenio
            IF vr_flgfirst THEN

              -- nomendo os arquivos
              pc_nomeia_arquivos;

              --nome do arquivo lst
              vr_nmarqrel := 'crrl342_c'||LPAD(rw_gnconve.cdconven,4,'0')||'.lst';

              --instanciando o clob
              dbms_lob.createtemporary(vr_des_xml, true);
              dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

              --instanciando o clob do
              dbms_lob.createtemporary(vr_des_xml2, true);
              dbms_lob.open(vr_des_xml2, dbms_lob.lob_readwrite);

              -- iniciando o arquivo xml para gerar o lst
              gene0002.pc_escreve_xml(vr_des_xml,
                                      vr_texto_completo,
                                      '<?xml version="1.0" encoding="utf-8"?><crrl342>'||
                                      '<arquivo nomearq="'||vr_nmarqdat||'" '||
                                               'dstipo="'||rw_gnconve.dstipo||'" '||
                                               'dtproxim="'||TO_CHAR(vr_dtproxim,'DD/MM/YYYY')||'" '||
                                               'nmempres="'||vr_nmempres||'" '||
                                               'nmcidade1="'||vr_vet_nmcidade(1)||'" '||
                                               'nmcidade2="'||vr_vet_nmcidade(2)||'" '||
                                               'nmrescop1="'||vr_vet_nmrescop(1)||'" '||
                                               'nmrescop2="'||vr_vet_nmrescop(2)||'">'||
                                               chr(13));

              -- iniciando o arquivo que será enviado
              gene0002.pc_escreve_xml(vr_des_xml2,
                                      vr_texto_completo2,
                                      'A2'||
                                      RPAD(vr_nrconven,8,' ') ||
                                      '            '          ||
                                      RPAD(vr_nmempcov,20,' ')||
                                      LPAD(vr_nrdbanco,3,'0') ||
                                      RPAD(vr_nmdbanco,20,' ')||
                                      TO_CHAR(rw_crapdat.dtmvtolt,'YYYYMMDD')||
                                      LPAD(vr_nrseqarq,6,'0')||
                                      '03CODIGO DE BARRAS '||
                                      '                              '||
                                      '                      '||chr(13)||chr(10));

              --mudando o flag para false de modo a não gerar novamente o cabecalho
              vr_flgfirst := FALSE;

            END IF;--IF vr_flgfirst THEN

            --Prefeitura Gaspar / Prefeitura Pomerode
            IF rw_gnconve.cdhiscxa IN (398,663) THEN
              --busca o valor do titulo no codigo de barras da fatura
              vr_vltitulo := TO_NUMBER(SUBSTR(rw_craplft.cdbarras, 05, 11))/ 100;

              --se o valor do codigo de barras estiver zerado,
              --busca na coluna de valor da tabela
              IF vr_vltitulo = 0 THEN
                vr_vltitulo := rw_craplft.vllanmto;
              END IF;

              --acumulando o valor do titulo
              vr_tot_vltitulo := nvl(vr_tot_vltitulo,0) + vr_vltitulo;
            END IF;--IF rw_ gnconve.cdhiscxa IN (398,663) THEN

            --atualizando o sequencial de linhas
            vr_nrseqdig     := nvl(vr_nrseqdig,0) + 1;
            --acumulando o valor total da fatura
            vr_tot_vlfatura := nvl(vr_tot_vlfatura,0) + rw_craplft.vllanmto;
            --acumula o valor total de tarifas
            vr_tot_vltarifa := nvl(vr_tot_vltarifa,0) + nvl(vr_vltarifa,0);
            --monta o codigo de pesquisa
            vr_cdpeslft     := TO_CHAR(rw_craplft.dtmvtolt,'DD/MM/YYYY') || '-' ||
                               LPAD(rw_craplft.cdagenci,3,'0')           || '-' ||
                               LPAD(rw_craplft.cdbccxlt,3,'0')           || '-' ||
                               LPAD(rw_craplft.nrdolote,6,'0');            

            --
            IF rw_craplft.cdagenci = 90 THEN  -- Internet
              vr_tot_qtfatint := nvl(vr_tot_qtfatint,0) + 1;
              vr_tot_vlfatint := nvl(vr_tot_vlfatint,0) + rw_craplft.vllanmto;
              vr_tot_vltarint := nvl(vr_tot_vltarint,0) + nvl(vr_vltarifa,0);
            ELSIF rw_craplft.cdagenci = 91 THEN -- TAA
              vr_tot_qtfattaa := nvl(vr_tot_qtfattaa,0) + 1;
              vr_tot_vlfattaa := nvl(vr_tot_vlfattaa,0) + rw_craplft.vllanmto;
              vr_tot_vltartaa := nvl(vr_tot_vltartaa,0) + nvl(vr_vltarifa,0);
            ELSE -- caixa
              vr_tot_qtfatcxa := nvl(vr_tot_qtfatcxa,0) + 1;
              vr_tot_vlfatcxa := nvl(vr_tot_vlfatcxa,0) + rw_craplft.vllanmto;
              vr_tot_vltarcxa := nvl(vr_tot_vltarcxa,0) + nvl(vr_vltarifa,0);
            END IF;

            -- Se nao for Prefeitura Gaspar / Prefeitura Pomerode
            IF rw_gnconve.cdhiscxa NOT IN (398, 663) THEN
              --armazena o codigo de sequencia do faturamento
              vr_cdseqfat := SUBSTR(rw_craplft.cdseqfat,1,20);

              -- escrevendo no clob para lancamento normal
              gene0002.pc_escreve_xml(vr_des_xml,
                                      vr_texto_completo,
                                      '<lancamento idlancto="'||rw_craplft.rowid||'">'||
                                        '<cdpeslft>'||vr_cdpeslft||'</cdpeslft>'||
                                        '<nrseqdig>'||rw_craplft.nrseqdig||'</nrseqdig>'||
                                        '<dtvencto>'||TO_CHAR(rw_craplft.dtvencto,'DD/MM/YYYY')||'</dtvencto>'||
                                        '<cdseqfat>'||vr_cdseqfat||'</cdseqfat>'||
                                        '<nrdigfat>'||rw_craplft.nrdigfat||'</nrdigfat>'||
                                        '<vllanmto>'||rw_craplft.vllanmto||'</vllanmto>'||
                                        '<vltitulo>0</vltitulo>'||
                                        '<cdagenci>'||rw_craplft.cdagenci||'</cdagenci>'||
                                      '</lancamento>'||chr(13));
            ELSE
              -- escrevendo no clob ref. iptu
              gene0002.pc_escreve_xml(vr_des_xml,
                                      vr_texto_completo,
                                      '<lancamento idlancto="'||rw_craplft.rowid||'">'||
                                        '<cdpeslft>'||vr_cdpeslft||'</cdpeslft>'||
                                        '<nrseqdig>'||rw_craplft.nrseqdig||'</nrseqdig>'||
                                        '<dtvencto>'||TO_CHAR(rw_craplft.dtmvtolt,'DD/MM/YYYY')||'</dtvencto>'||
                                        '<cdseqfat></cdseqfat>'||
                                        '<nrdigfat></nrdigfat>'||
                                        '<vllanmto>'||rw_craplft.vllanmto||'</vllanmto>'||
                                        '<vltitulo>'||vr_vltitulo||'</vltitulo>'||
                                        '<cdagenci>'||rw_craplft.cdagenci||'</cdagenci>'||
                                      '</lancamento>'||chr(13));
            END IF;
            
            -- gravar agencia para mandar no arquivo
            vr_cdcoppac := LPAD(rw_crapcop.cdagectl,5,'0');            

            --gera o numero da autorizacao
            vr_nrautdoc := LPAD(rw_crapcop.cdcooper, 2, '0')||
                           LPAD(rw_craplft.cdagenci,3,'0')  ||
                           SUBSTR(rw_craplft.nrdolote,3,3)  ||
                           LPAD(rw_craplft.nrautdoc,9, '0');

            IF rw_craplft.cdagenci = 90 OR    /* Pagamento feito pela Internet */
               rw_craplft.cdhistor = 348 THEN /** CASAN **/
              -- 3- Internet
              vr_tipopagto := '3';
            ELSIF rw_craplft.cdagenci = 91 THEN  /* Pagamento feito atraves de TAA **/
              -- 2- TAA
              vr_tipopagto := '2';
            ELSE /* Pagamento no Caixa */
              -- 1- Boca de caixa
              vr_tipopagto := '1';
            END IF;

            --montando a linha do arquivo
            vr_dslinreg :=  'G'||
                            vr_cdcoppac||
                            LPAD(' ',15,' ')||
                            TO_CHAR(rw_crapdat.dtmvtolt,'YYYYMMDD')||
                            TO_CHAR(vr_dtproxim, 'YYYYMMDD')||
                            RPAD(rw_craplft.cdbarras,44,' ')||
                            LPAD(rw_craplft.vllanmto * 100,12,'0')||
                            LPAD(vr_vltarifa * 100,7,'0')||
                            LPAD(vr_nrseqdig, 8,'0')||
                            RPAD(vr_cdcoppac, 8,' ')||
                            vr_tipopagto||
                            RPAD(' ', 6,' ')||
                            vr_nrautdoc ||
                            '1'||
                            RPAD(' ',9,' ');

            --gerando a linha do arquivo no clob
            gene0002.pc_escreve_xml(vr_des_xml2,
                                    vr_texto_completo2,
                                    vr_dslinreg||chr(13)||chr(10));

            --se o convenio eh unico
            IF rw_gnconve.flgcvuni = 1 THEN
              BEGIN
                INSERT INTO gncvuni( cdcooper
                                    ,cdconven
                                    ,dtmvtolt
                                    ,flgproce
                                    ,nrseqreg
                                    ,dsmovtos
                                    ,tpdcontr
                ) VALUES ( rw_crapcop.cdcooper
                          ,rw_gnconve.cdconven
                          ,rw_crapdat.dtmvtolt
                          ,0 -- false
                          ,vr_nrseqdig
                          ,vr_dslinreg
                          ,1 -- Tipo Caixa
                );
              EXCEPTION
                WHEN OTHERS THEN
                  -- gerando a critica
                  vr_dscritic := 'Erro ao inserir dados na tabela gncvuni. '||SQLERRM;
                  -- abortando a execucao
                  RAISE vr_exc_saida;
              END;
            END IF;
          END LOOP;
          --fecha o cursor
          CLOSE cr_craplft;

          --se não é primeiro registro do convenio
          IF NOT vr_flgfirst THEN
            --gerando os totais
            vr_tot_qtapagar := nvl(vr_tot_qtfatcxa,0) +
                               nvl(vr_tot_qtfatint,0) +
                               nvl(vr_tot_qtfattaa,0);

            vr_tot_vlapagar := nvl(vr_tot_vlfatura,0) - nvl(vr_tot_vltarifa,0);
            vr_tot_vlpagcxa := nvl(vr_tot_vlfatcxa,0) - nvl(vr_tot_vltarcxa,0);
            vr_tot_vlpagint := nvl(vr_tot_vlfatint,0) - nvl(vr_tot_vltarint,0);
            vr_tot_vlpagtaa := nvl(vr_tot_vlfattaa,0) - nvl(vr_tot_vltartaa,0);

            --se é Gaspar ou Pomerode
            IF rw_gnconve.cdhiscxa NOT IN (398, 663)THEN -- Pref.Gaspar / --Prefeitura Pomerode
              -- totalizando
              gene0002.pc_escreve_xml(vr_des_xml,
                                      vr_texto_completo,
                                      '<total>'||
                                        '<qtfatcxa>'||LPAD('FATURAS CAIXA:',41,' ')||LPAD(TO_CHAR(vr_tot_qtfatcxa,'fm999G999G999'),20,' ')||'</qtfatcxa>'||
                                        '<vlfatcxa>'||LPAD('ARRECADADO CAIXA:',41,' ')||LPAD(TO_CHAR(vr_tot_vlfatcxa,'fm999G999G990D00'),20,' ')||'</vlfatcxa>'||
                                        '<vltrfcxa></vltrfcxa>'||
                                        '<vltarcxa>'||LPAD('TARIFAS CAIXA:',41,' ')||LPAD(TO_CHAR(vr_tot_vltarcxa,'fm999G999G990D00'),20,' ')||'</vltarcxa>'||
                                        '<vlpagcxa>'||LPAD('A PAGAR CAIXA:',41,' ')||LPAD(TO_CHAR(vr_tot_vlpagcxa,'fm999G999G990D00'),20,' ')||'</vlpagcxa>'||
                                        '<nrseqdig_tot>'||LPAD(vr_nrseqdig,20,' ')||'</nrseqdig_tot>'||
                                        '<qtfatint>'||LPAD('FATURAS INTERNET:',41,' ')||LPAD(TO_CHAR(vr_tot_qtfatint,'fm999G999G999'),20,' ')||'</qtfatint>'||
                                        '<vlfatint>'||LPAD('ARRECADADO INTERNET:',41,' ')||LPAD(TO_CHAR(vr_tot_vlfatint,'fm999G999G990D00'),20,' ')||'</vlfatint>'||
                                        '<vltrfnet></vltrfnet>'||
                                        '<vltarint>'||LPAD('TARIFAS INTERNET:',41,' ')||LPAD(TO_CHAR(vr_tot_vltarint,'fm999G999G990D00'),20,' ')||'</vltarint>'||
                                        '<vlpagint>'||LPAD('A PAGAR INTERNET:',41,' ')||LPAD(TO_CHAR(vr_tot_vlpagint,'fm999G999G990D00'),20,' ')||'</vlpagint>'||
                                        '<qtfattaa>'||LPAD('FATURAS TAA:',41,' ')||LPAD(TO_CHAR(vr_tot_qtfattaa,'fm999G999G999'),20,' ')||'</qtfattaa>'||
                                        '<vlfattaa>'||LPAD('ARRECADADO TAA:',41,' ')||LPAD(TO_CHAR(vr_tot_vlfattaa,'fm999G999G990D00'),20,' ')||'</vlfattaa>'||
                                        '<vltrftaa></vltrftaa>'||
                                        '<vltartaa>'||LPAD('TARIFAS TAA:',41,' ')||LPAD(TO_CHAR(vr_tot_vltartaa,'fm999G999G990D00'),20,' ')||'</vltartaa>'||
                                        '<vlpagtaa>'||LPAD('A PAGAR TAA:',41,' ')||LPAD(TO_CHAR(vr_tot_vlpagtaa,'fm999G999G990D00'),20,' ')||'</vlpagtaa>'||
                                        '<vlfatura_tot>'||LPAD('TOTAL ARRECADADO:',41,' ')||LPAD(TO_CHAR(vr_tot_vlfatura,'fm999G999G990D00'),20,' ')||'</vlfatura_tot>'||
                                        '<vltitulo_tot></vltitulo_tot>'||
                                        '<vltarifa_tot>'||LPAD('TOTAL DE TARIFAS:',41,' ')||LPAD(TO_CHAR(vr_tot_vltarifa,'fm999G999G990D00'),20,' ')||'</vltarifa_tot>'||
                                        '<vlapagar_tot>'||LPAD('TOTAL A PAGAR:',41,' ')||LPAD(TO_CHAR(vr_tot_vlapagar,'fm999G999G990D00'),20,' ')||'</vlapagar_tot>'||
                                        '<qtapagar_tot>'||LPAD('QUANTIDADE DE FATURAS:',41,' ')||LPAD(TO_CHAR(vr_tot_qtapagar,'fm999G999G999'),20,' ')||'</qtapagar_tot>'||
                                      '</total>'||chr(13));

            ELSE
              -- totalizando
              gene0002.pc_escreve_xml(vr_des_xml,
                                      vr_texto_completo,
                                      '<total>'||
                                        '<qtfatcxa>'||LPAD('FATURAS CAIXA:',41,' ')||LPAD(TO_CHAR(vr_tot_qtfatcxa,'fm999G999G999'),20,' ')||'</qtfatcxa>'||
                                        '<vlfatcxa>'||LPAD('VALOR PAGO CAIXA:',41,' ')||LPAD(TO_CHAR(vr_tot_vlfatcxa,'fm999G999G990D00'),20,' ')||'</vlfatcxa>'||
                                        '<vltrfcxa>'||LPAD('VALOR TARIFA CAIXA:',41,' ')||LPAD(TO_CHAR(rw_gnconve.vltrfcxa,'fm999G999G990D00'),20,' ')||'</vltrfcxa>'||
                                        '<vltarcxa>'||LPAD('TOTAL TARIFAS CAIXA:',41,' ')||LPAD(TO_CHAR(vr_tot_vltarcxa,'fm999G999G990D00'),20,' ')||'</vltarcxa>'||
                                        '<vlpagcxa>'||LPAD('A PAGAR CAIXA:',41,' ')||LPAD(TO_CHAR(vr_tot_vlpagcxa,'fm999G999G990D00'),20,' ')||'</vlpagcxa>'||
                                        '<nrseqdig_tot>'||LPAD(vr_nrseqdig,20,' ')||'</nrseqdig_tot>'||
                                        '<qtfatint>'||LPAD('FATURAS INTERNET:',41,' ')||LPAD(TO_CHAR(vr_tot_qtfatint,'fm999G999G999'),20,' ')||'</qtfatint>'||
                                        '<vlfatint>'||LPAD('VALOR PAGO INTERNET:',41,' ')||LPAD(TO_CHAR(vr_tot_vlfatint,'fm999G999G990D00'),20,' ')||'</vlfatint>'||
                                        '<vltrfnet>'||LPAD('VALOR TARIFA INTERNET:',41,' ')||LPAD(TO_CHAR(rw_gnconve.vltrfnet,'fm999G999G990D00'),20,' ')||'</vltrfnet>'||
                                        '<vltarint>'||LPAD('TOTAL TARIFAS INTERNET:',41,' ')||LPAD(TO_CHAR(vr_tot_vltarint,'fm999G999G990D00'),20,' ')||'</vltarint>'||
                                        '<vlpagint>'||LPAD('A PAGAR INTERNET:',41,' ')||LPAD(TO_CHAR(vr_tot_vlpagint,'fm999G999G990D00'),20,' ')||'</vlpagint>'||
                                        '<qtfattaa>'||LPAD('FATURAS TAA:',41,' ')||LPAD(TO_CHAR(vr_tot_qtfattaa,'fm999G999G999'),20,' ')||'</qtfattaa>'||
                                        '<vlfattaa>'||LPAD('VALOR PAGO TAA:',41,' ')||LPAD(TO_CHAR(vr_tot_vlfattaa,'fm999G999G990D00'),20,' ')||'</vlfattaa>'||
                                        '<vltrftaa>'||LPAD('VALOR TARIFA TAA:',41,' ')||LPAD(TO_CHAR(rw_gnconve.vltrftaa,'fm999G999G990D00'),20,' ')||'</vltrftaa>'||
                                        '<vltartaa>'||LPAD('TOTAL TARIFAS TAA:',41,' ')||LPAD(TO_CHAR(vr_tot_vltartaa,'fm999G999G990D00'),20,' ')||'</vltartaa>'||
                                        '<vlpagtaa>'||LPAD('A PAGAR TAA:',41,' ')||LPAD(TO_CHAR(vr_tot_vlpagtaa,'fm999G999G990D00'),20,' ')||'</vlpagtaa>'||
                                        '<vlfatura_tot>'||LPAD('TOTAL VALOR PAGO:',41,' ')||LPAD(TO_CHAR(vr_tot_vlfatura,'fm999G999G990D00'),20,' ')||'</vlfatura_tot>'||
                                        '<vltitulo_tot>'||LPAD('TOTAL VALOR TITULO:',41,' ')||LPAD(TO_CHAR(vr_tot_vltitulo,'fm999G999G990D00'),20,' ')||'</vltitulo_tot>'||
                                        '<vltarifa_tot>'||LPAD('TOTAL DA TARIFA:',41,' ')||LPAD(TO_CHAR(vr_tot_vltarifa,'fm999G999G990D00'),20,' ')||'</vltarifa_tot>'||
                                        '<vlapagar_tot>'||LPAD('TOTAL A PAGAR:',41,' ')||LPAD(TO_CHAR(vr_tot_vlapagar,'fm999G999G990D00'),20,' ')||'</vlapagar_tot>'||
                                        '<qtapagar_tot>'||LPAD('QUANTIDADE DE FATURAS:',41,' ')||LPAD(TO_CHAR(vr_tot_qtapagar,'fm999G999G999'),20,' ')||'</qtapagar_tot>'||
                                      '</total>'||chr(13));
            END IF;

            --gerando a linha do arquivo no clob
            gene0002.pc_escreve_xml(vr_des_xml2,
                                    vr_texto_completo2,
                                    'Z'||
                                    LPAD(vr_nrseqdig + 2, 6, '0')||
                                    LPAD(vr_tot_vlfatura * 100,17,'0')||
                                    '                                        '||
                                    '                                        '||
                                    '                                              '||chr(13)||chr(10));


            --finalizando o clob
            gene0002.pc_escreve_xml(vr_des_xml,
                                    vr_texto_completo,
                                    '</arquivo></crrl342>',TRUE);

            --finalizando o clob
            gene0002.pc_escreve_xml(vr_des_xml2,
                                    vr_texto_completo2,
                                    '',TRUE);
            
            --Criar o arquivo no diretorio especificado
            gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml2
                                         ,pr_caminho  => vr_path_arquivo||'/arq/'
                                         ,pr_arquivo  => vr_nmarqped
                                         ,pr_des_erro => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            
            
            -- Gerando o relatório
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                       ,pr_cdprogra  => vr_cdprogra
                                       ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                       ,pr_dsxml     => vr_des_xml
                                       ,pr_dsxmlnode => '/crrl342/arquivo/lancamento'
                                       ,pr_dsjasper  => 'crrl342.jasper'
                                       ,pr_dsparams  => ''
                                       ,pr_dsarqsaid => vr_path_arquivo ||'/rl/'||vr_nmarqrel
                                       ,pr_flg_gerar => vr_gerar
                                       ,pr_qtcoluna  => 80
                                       ,pr_sqcabrel  => 1
                                       ,pr_flg_impri => 'S'
                                       ,pr_nmformul  => '80col'
                                       ,pr_nrcopias  => 1
                                       ,pr_des_erro  => vr_dscritic);


            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);

            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml2);
            dbms_lob.freetemporary(vr_des_xml2);

            --se nao for convenio unico, transmite o arquivo
            IF rw_gnconve.flgcvuni = 0 THEN
              pc_transmite_arquivo;
            ELSE
              -- Comando para copiar o arquivo para a pasta salvar
              vr_comando:= 'mv '||vr_path_arquivo||'/arq/'||vr_nmarqped||' '||vr_path_arquivo||'/salvar'||' 2> /dev/null';

              --Executar o comando no unix
              GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_comando
                                  ,pr_typ_saida   => vr_typ_saida
                                  ,pr_des_saida   => vr_dscritic);

              --Se ocorreu erro dar RAISE
              IF vr_typ_saida = 'ERR' THEN
               vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
               -- retornando ao programa chamador
               RAISE vr_exc_saida;
              END IF;

            END IF;

            pc_atualiza_controle;

          ELSE
            --montando a critica de movimento
            vr_dscritic := 'Sem movtos Convenio - ' || rw_gnconve.cdconven || '  - ' || rw_gnconve.nmempres;

            -- Gerando mensagem no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Mensagem
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );

            --limpando a variavel de critica
            vr_dscritic := NULL;

            IF rw_crapcop.cdcooper = 1 AND
               rw_gnconve.cdhiscxa IN (396,663) AND -- SAMAE Jaragua do Sul / Prefeitura Pomerode  */
               rw_gnconve.flgcvuni = 0  THEN
              --envia email
              pc_envia_email_sem_movimento;
            END IF;
          END IF; --IF NOT vr_flgfirst THEN
        END;
      END pc_efetua_geracao_arquivos;

      --subrotina para dividir o nome da cooperativa em duas partes
      PROCEDURE pc_divinome IS
      BEGIN
        DECLARE
          vr_split_nmextcop GENE0002.typ_split;
          vr_indsplit       INTEGER;
          vr_qtpalavr       INTEGER;
        BEGIN
          -- Quebra o nome completo da cooperativa pelo delimitador ' '
          vr_split_nmextcop := gene0002.fn_quebra_string(rw_crapcop.nmextcop, ' ');

          --verifica a quantidade de palavras em cada string
          vr_qtpalavr := vr_split_nmextcop.count / 2;

          --inicializa o vetor
          vr_vet_nmrescop := typ_tab_varchar(NULL, NULL);

          --posiciona no primeiro registro
          vr_indsplit := vr_split_nmextcop.first;

          --percorre o vetor de nomes
          LOOP
            EXIT WHEN vr_indsplit IS NULL;

            --se é menor, vai para a primeira quebra senão
            --joga o valor na segunda linha da quebra
            IF vr_indsplit <= vr_qtpalavr THEN
              IF vr_vet_nmrescop(1) IS NULL THEN
                vr_vet_nmrescop(1) := vr_split_nmextcop(vr_indsplit);
              ELSE
                vr_vet_nmrescop(1) := vr_vet_nmrescop(1) ||' '||vr_split_nmextcop(vr_indsplit);
              END IF;
            ELSE
              IF vr_vet_nmrescop(2) IS NULL THEN
                vr_vet_nmrescop(2) := vr_split_nmextcop(vr_indsplit);
              ELSE
                vr_vet_nmrescop(2) := vr_vet_nmrescop(2) ||' '||vr_split_nmextcop(vr_indsplit);
              END IF;
            END IF;
            --vai para o proximo registro
            vr_indsplit := vr_split_nmextcop.next(vr_indsplit);
          END LOOP;
        END;
      END pc_divinome;

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
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
            
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      --busca o diretorio da cooperativa conectada
      vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_nmsubdir => ''); --> Gerado no diretorio /rl


      vr_vet_nmcidade(1) := TRIM(rw_crapcop.nmcidade) || ', ';
      vr_vet_nmcidade(2) := TRIM(rw_crapcop.nmcidade) || ' - '||TRIM(rw_crapcop.cdufdcop);

      -- divida o nome da cooperativa em duas strings
      pc_divinome;

      --antecipa a data de movimento em cinco dias
      vr_dtanteri := rw_crapdat.dtmvtolt - 5;

      --percorre os convenios da cooperativa
      OPEN cr_gnconve ( pr_cdcooper => pr_cdcooper);
      LOOP
        FETCH cr_gnconve INTO rw_gnconve;
        EXIT WHEN cr_gnconve%NOTFOUND;

        -- Tipo de repasse D+1
        IF rw_gnconve.tprepass = 1 THEN        
          vr_dtproxim := gene0005.fn_valida_dia_util(pr_cdcooper,
                                                     rw_crapdat.dtmvtopr);
        ELSE -- Tipo de repasse D+2
          vr_dtproxim := gene0005.fn_valida_dia_util(pr_cdcooper,
                                                     rw_crapdat.dtmvtopr + 1);
        END IF;                                                     

        -- monta o roda pe do relatorio
        vr_vet_nmcidade(1) := TRIM(rw_crapcop.nmcidade) || ', ' ||
                              TO_CHAR(vr_dtproxim,'DD')||
                              ' DE '||
                              TO_CHAR(vr_dtproxim,'MONTH')||
                              ' DE '||
                              TO_CHAR(vr_dtproxim,'YYYY');

        --nome da empresa
        vr_nmempres := rw_gnconve.nmempres;

        --indica que é o primeiro convenio
        vr_flgfirst     := TRUE;
        vr_nrseqdig     := 0;
        vr_tot_vlfatura := 0;
        vr_tot_vltarifa := 0;
        vr_tot_vlapagar := 0;
        vr_tot_qtfatcxa := 0;
        vr_tot_vlfatcxa := 0;
        vr_tot_vltarcxa := 0;
        vr_tot_vlpagcxa := 0;
        vr_tot_qtfatint := 0;
        vr_tot_vlfatint := 0;
        vr_tot_vltarint := 0;
        vr_tot_vlpagint := 0;
        vr_tot_qtfattaa := 0;
        vr_tot_vlfattaa := 0;
        vr_tot_vltartaa := 0;
        vr_tot_vlpagtaa := 0;
        vr_tot_vlfatur2 := 0;
        vr_tot_vlorpago := 0;
        vr_tot_vltitulo := 0;

        --definindo a data de processamento
        vr_dtproces := rw_crapdat.dtmvtolt;

        --verifica se possui faturas
        OPEN cr_craplft ( pr_cdcooper => pr_cdcooper
                         ,pr_dtvencto => vr_dtanteri
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdhistor => rw_gnconve.cdhiscxa);
        FETCH cr_craplft INTO rw_craplft;
        --se encontrar alguma fatura
        IF cr_craplft%FOUND THEN
          --muda a data do processamento para pela data do vencimento da fatura
          vr_dtproces := rw_craplft.dtvencto;
        END IF;
        --fecha o cursor
        CLOSE cr_craplft;

        -- inicia a geracao dos arquivos
        pc_efetua_geracao_arquivos;

        --se nao eh o primeiro registro
        IF (NOT vr_flgfirst) THEN

          BEGIN
            --atualizando a situacao e a data de envio da fatura
            UPDATE craplft SET craplft.insitfat = 2
                              ,craplft.dtdenvio = vr_dtproxim
            WHERE craplft.cdcooper  = pr_cdcooper
            AND   craplft.dtvencto >= vr_dtproces
            AND   craplft.dtvencto <= rw_crapdat.dtmvtolt
            AND   craplft.insitfat  = 1
            AND   craplft.cdhistor  = rw_gnconve.cdhiscxa;

          EXCEPTION
            WHEN no_data_found THEN
              --gerando a critica
              vr_dscritic := 'Erro ao atualizar a tabela craplft. '||SQLERRM;
              -- abortando a execucao
              RAISE vr_exc_saida;
          END;
        END IF;

        -- Salvar informações a cada convenio processado
        COMMIT;      

      END LOOP;--FOR rw_gnconve IN cr_gnconve ( pr_cdcooper => pr_cdcooper)
      --fecha o cursor
      CLOSE cr_gnconve;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);


      -- Salvar informações atualizadas
      COMMIT;      

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
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
        -- Devolvemos código e critica encontradas das variaveis locais
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
  END pc_crps385;
