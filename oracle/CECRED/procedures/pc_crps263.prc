CREATE OR REPLACE PROCEDURE CECRED.pc_crps263(pr_cdcooper  IN craptab.cdcooper%TYPE,
                                       pr_flgresta  IN PLS_INTEGER,            --> Flag padrão para utilização de restart
                                       pr_stprogra OUT PLS_INTEGER,            --> Saída de termino da execução
                                       pr_infimsol OUT PLS_INTEGER,            --> Saída de termino da solicitação,
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                       pr_dscritic OUT VARCHAR2) IS
BEGIN
/* ............................................................................

   Programa: PC_CRPS263 (Antigo Fontes/crps263.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah          
   Data    : Maio/99                             Ultima atualizacao: 10/02/2015

   Dados referentes ao programa:

   Frequencia: QUINZENAL
   Objetivo  : Atende a solicitacao 089
               Ordem 4
               Relatorio 213 - Seguros de automoveis a vencer no mes seguinte.
                               
   Alteracoes: 24/08/2000 - Impressao em 2 vias (Deborah).
               
               11/10/2000 - Alterar para 20 posicoes fone (Margarete/Planner).

               16/02/2005 - Alterado para rodar sempre na primeira quinzena
                            do mes (Edson).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               22/02/2008 - Alterado para mostrar turno a partir da 
                            crapttl.cdturnos (Gabriel).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
                        
                          - Excluir colunas EMP e TU, ajustar Telefone. Rel 213
                            (Gabriel).

               02/08/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).   
               
               01/10/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               04/10/2013 - Remocao de codigo depois do for each dos seguros.
                            Inclusao do total de seguros a vencer de todos os
                            PAs da cooperativa (Carlos)
                            
               10/02/2015 - Conversão Progress >> Oracle PL/SQL (Vanessa).
............................................................................. */

   DECLARE
    ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    
     -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_exc_fimprg    EXCEPTION;
      vr_cdcritic      PLS_INTEGER;
      vr_dscritic      VARCHAR2(4000);     

      -- Variáveis locais do bloco
      vr_xml_clobxml   CLOB;
      vr_des_xml       VARCHAR(32600) := NULL;
      vr_xml_des_erro  VARCHAR2(4000);
      vr_pa_anterior   NUMBER         := 0;
      vr_pa_proximo    BOOLEAN; 

      -- Variáveis do cprs
      vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS263';       --> Código do programa
      vr_dsdireto   VARCHAR2(200);                                     --> Caminho
      vr_dsdireto_rlnsv  VARCHAR2(200);                                --> Caminho /rlnsv
     
      vr_dtrefini  DATE;
      vr_dtreffim  DATE;
      vr_nrtelefo  VARCHAR2(30);
      vr_qtdtotreg NUMBER          := 0; 
      
      -- Tabela temporaria para os telefones
      TYPE typ_reg_telefones IS 
       RECORD(nrtelefo craptfc.nrtelefo%TYPE );
      TYPE typ_tab_telefones IS
        TABLE OF typ_reg_telefones
          INDEX BY VARCHAR2(15); --cdcooper(3) + nrdconta(10) + tptelefo(2)
      
      -- Vetor para armazenar os telefones dos cooperados
      vr_tab_telefones typ_tab_telefones;
      
      -- Variavel para o indice
      vr_indice_telefone VARCHAR2(15); 
      vr_indice_telcel VARCHAR2(15); 
      vr_indice_telres VARCHAR2(15); 
      vr_indice_telcom VARCHAR2(15); 
      vr_indice_telcon VARCHAR2(15); 
      ---------------- Cursores genéricos ----------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nrctactl
              ,cop.dsdircop
              ,cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      --Cursor que busca os seguros a vencer
      CURSOR cr_crapseg(pr_cdcooper IN craptab.cdcooper%TYPE,
                        pr_dtrefini IN crapdat.dtmvtolt%TYPE,
                        pr_dtreffim IN crapdat.dtmvtolt%TYPE) IS
         SELECT seg.cdcooper,
                ass.cdagenci,
                ass.nmprimtl,
                seg.dtfimvig,
                seg.nrctrseg,
                seg.nrdconta,
                age.nmresage 
           FROM crapseg seg,
                crapass ass,
                crapage age
          WHERE ass.cdcooper = seg.cdcooper  AND
                ass.nrdconta = seg.nrdconta  AND
                age.cdcooper = ass.cdcooper  AND
                age.cdagenci = ass.cdagenci  AND 
                seg.cdcooper = pr_cdcooper       AND
                seg.tpseguro = 2                 AND
                seg.dtfimvig BETWEEN pr_dtrefini AND pr_dtreffim       AND
                seg.dtcancel IS NULL             AND
                seg.nrctratu = 0                      
                GROUP BY seg.cdcooper,
                         ass.cdagenci,
                         ass.nmprimtl,
                         seg.dtfimvig,
                         seg.nrctrseg,
                         seg.nrdconta,
                         age.nmresage
                 ORDER BY ass.cdagenci, seg.dtfimvig, seg.nrctrseg ASC;
       rw_crapseg cr_crapseg%ROWTYPE;
       
       -- Cursor para buscar o telefone do cooperado
       CURSOR cr_craptfc(pr_cdcooper IN craptab.cdcooper%TYPE,
                        pr_dtrefini IN crapdat.dtmvtolt%TYPE,
                        pr_dtreffim IN crapdat.dtmvtolt%TYPE) IS
                                    
           SELECT tfc.tptelefo,
                  seg.cdcooper,               
                  seg.nrdconta,             
                  tfc.nrtelefo
             FROM crapseg seg,
                  craptfc tfc
            WHERE tfc.cdcooper = seg.cdcooper      AND
                  tfc.nrdconta = seg.nrdconta      AND
                  seg.cdcooper = pr_cdcooper       AND
                  seg.tpseguro = 2                 AND
                  seg.dtfimvig BETWEEN pr_dtrefini AND pr_dtreffim AND
                  seg.dtcancel IS NULL             AND
                  seg.nrctratu = 0                 AND                
                  tfc.idseqttl = 1
             ORDER BY tfc.nrtelefo ASC;
       rw_craptfc cr_craptfc%ROWTYPE; 
       
      --Cursor para buscar informações do seguro e seguradora
       CURSOR cr_crawseg(pr_cdcooper IN craptab.cdcooper%TYPE,
                         pr_nrdconta IN crapass.nrdconta%TYPE,
                         pr_nrctrseg IN crapseg.nrctrseg%TYPE) IS
         SELECT csg.nmresseg,
                seg.dsmarvei,
                seg.dstipvei,
                seg.nrmodvei,
                seg.nranovei,
                seg.nrdplaca,
                seg.cdsegura
 
           FROM crawseg seg
                ,crapcsg csg 
          WHERE csg.cdcooper(+) = seg.cdcooper AND
                csg.cdsegura(+) = seg.cdsegura AND
                seg.cdcooper = pr_cdcooper     AND
                seg.nrdconta = pr_nrdconta     AND
                seg.nrctrseg = pr_nrctrseg;
       rw_crawseg cr_crawseg%ROWTYPE;
      
       
      
    BEGIN
      
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
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
     
      vr_dtreffim := TRUNC(ADD_MONTHS(LAST_DAY(rw_crapdat.dtmvtolt),1));
      vr_dtrefini := TRUNC(LAST_DAY(ADD_MONTHS(vr_dtreffim,-1))+1);
      vr_pa_anterior  := 0;       
      vr_pa_proximo   := FALSE;
      
      --Monta a tabela com as informações dos telefones
      FOR rw_craptfc IN cr_craptfc(pr_cdcooper => rw_crapcop.cdcooper,
                                   pr_dtrefini => vr_dtrefini,
                                   pr_dtreffim => vr_dtreffim) LOOP
                     
        -- Monta indice da PL/TABLE --cdcooper(3) + nrdconta(10) + tptelefo(2) 
        vr_indice_telefone := LPAD(rw_craptfc.cdcooper,3,'0') ||
                              LPAD(rw_craptfc.nrdconta,10,'0') ||
                              LPAD(rw_craptfc.tptelefo,2,'0');
       
        -- Armazena Valores na PL/TABLE
        vr_tab_telefones(vr_indice_telefone).nrtelefo := rw_craptfc.nrtelefo;
      END LOOP;
      
       -- Preparar o CLOB para armazenar as infos do arquivo
      dbms_lob.createtemporary(vr_xml_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_xml_clobxml, dbms_lob.lob_readwrite);
      
      -- Adiciona a linha ao XML 
      gene0002.pc_escreve_xml(pr_xml             => vr_xml_clobxml 
                              ,pr_texto_completo => vr_des_xml
                              ,pr_texto_novo     =>'<?xml version="1.0" encoding="utf-8"?>'||chr(10)||'<crrl213>'||chr(10));

      --Percorre os seguros a vencer -> cr_crapseg
      FOR rw_crapseg IN cr_crapseg(pr_cdcooper => rw_crapcop.cdcooper,
                     pr_dtrefini => vr_dtrefini,
                     pr_dtreffim => vr_dtreffim) LOOP
                     
           vr_qtdtotreg    := vr_qtdtotreg + 1;
            
          IF vr_pa_anterior <> rw_crapseg.cdagenci THEN
             IF vr_pa_proximo THEN
                -- Adiciona a linha ao XML 
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                                       ,pr_texto_completo => vr_des_xml
                                       ,pr_texto_novo     =>'<total>'||vr_qtdtotreg||'</total></agencia>');  
               
             END IF ;            
             -- Adiciona a linha ao XML da agencia 
             gene0002.pc_escreve_xml(pr_xml            => vr_xml_clobxml 
                                    ,pr_texto_completo => vr_des_xml
                                    ,pr_texto_novo     =>'<agencia cdagenci="'||rw_crapseg.cdagenci
                                     ||'" nmextage="'||rw_crapseg.nmresage
                                     ||'" qtdtotreg="'||vr_qtdtotreg
                                     ||'" dtmesref="'||TRIM(Upper(to_char(vr_dtreffim,'Month/YYYY')))||'">');
              vr_pa_proximo := TRUE;      
            
          END IF;  
          
          vr_pa_anterior  := rw_crapseg.cdagenci;
          
          -- Procura primeiro celular(2), depois   Residencial(1) ,Comercial(3) e Contato(4) 
        
          -- Monta indice da PL/TABLE  celular(2)
          vr_indice_telcel := LPAD(rw_crapseg.cdcooper,3,'0') ||
                              LPAD(rw_crapseg.nrdconta,10,'0') ||
                              LPAD(2,2,'0');
          -- Monta indice da PL/TABLE Residencial(1)
          vr_indice_telres := LPAD(rw_crapseg.cdcooper,3,'0') ||
                              LPAD(rw_crapseg.nrdconta,10,'0') ||
                              LPAD(1,2,'0');
          -- Monta indice da PL/TABLE Comercial(3)
          vr_indice_telcom  := LPAD(rw_crapseg.cdcooper,3,'0') ||
                              LPAD(rw_crapseg.nrdconta,10,'0') ||
                              LPAD(3,2,'0');
          -- Monta indice da PL/TABLE Contato(4) 
          vr_indice_telcon  := LPAD(rw_crapseg.cdcooper,3,'0') ||
                              LPAD(rw_crapseg.nrdconta,10,'0') ||
                              LPAD(4,2,'0');
          
          -- verifica se existe o registro na PL/TABLE
          IF vr_tab_telefones.EXISTS(vr_indice_telcel) THEN           
             vr_nrtelefo := vr_tab_telefones(vr_indice_telcel).nrtelefo;
          ELSIF vr_tab_telefones.EXISTS(vr_indice_telres) THEN            
             vr_nrtelefo := vr_tab_telefones(vr_indice_telres).nrtelefo;
          ELSIF vr_tab_telefones.EXISTS(vr_indice_telcom) THEN             
             vr_nrtelefo := vr_tab_telefones(vr_indice_telcom).nrtelefo;
          ELSIF vr_tab_telefones.EXISTS(vr_indice_telcon) THEN            
             vr_nrtelefo := vr_tab_telefones(vr_indice_telcon).nrtelefo; 
          ELSE 
             vr_nrtelefo := ' '; 
          END IF;
                
          --Busca Informações do Seguro e Seguradora
          OPEN cr_crawseg(rw_crapseg.cdcooper,
                          rw_crapseg.nrdconta,
                          rw_crapseg.nrctrseg);
          FETCH cr_crawseg INTO rw_crawseg;

          -- Se nao encontrar
          IF cr_crawseg%NOTFOUND THEN
            -- Fechar o cursor pois havera raise
            CLOSE cr_crawseg;
            -- Montar mensagem de critica
            vr_cdcritic := 524;
            RAISE vr_exc_fimprg;
          ELSE
            IF rw_crawseg.nmresseg IS NULL THEN
              -- Montar mensagem de critica de seguradora não cadastrada
              vr_cdcritic := 556;
              RAISE vr_exc_fimprg;
            END IF;
            -- Fechar o cursor
            CLOSE cr_crawseg;
          END IF;
        
          -- Adiciona a linha ao XML 
          gene0002.pc_escreve_xml(pr_xml             => vr_xml_clobxml 
                                  ,pr_texto_completo => vr_des_xml
                                  ,pr_texto_novo     =>'<seguros>'
                                   ||chr(10)||'<dtfimvig>'||TO_CHAR(rw_crapseg.dtfimvig,'DD/MM/YYYY')||'</dtfimvig>'
                                   ||chr(10)||'<nmprimtl>'||TRIM(rw_crapseg.nmprimtl ) ||'</nmprimtl>'
                                   ||chr(10)||'<nrtelefo>'||TRIM(vr_nrtelefo)||'</nrtelefo>'
                                   ||chr(10)||'<nrdconta>'||TRIM(gene0002.fn_mask(rw_crapseg.nrdconta,'zzzz.zzz.z'))||'</nrdconta>'
                                   ||chr(10)||'<nmresseg>'||TRIM(rw_crawseg.nmresseg)||'</nmresseg>'
                                   ||chr(10)||'<dsveicul>'||TRIM(rw_crawseg.dsmarvei) || ' ' || TRIM(rw_crawseg.dstipvei)||'</dsveicul>'
                                   ||chr(10)||'<dsmodelo>'||TRIM(LPAD(rw_crawseg.nrmodvei,4,0)) || '/' || TRIM(LPAD(rw_crawseg.nranovei,4,0))||'</dsmodelo>'
                                   ||chr(10)||'<nrdplaca>'||TRIM(SUBSTR(rw_crawseg.nrdplaca,0,3) || '-' || SUBSTR(rw_crawseg.nrdplaca,4,4))||'</nrdplaca>'
                                   ||chr(10)||'</seguros>');  
          
        IF vr_pa_anterior <> rw_crapseg.cdagenci THEN
             -- Adiciona a linha ao XML 
              gene0002.pc_escreve_xml(pr_xml             => vr_xml_clobxml 
                                      ,pr_texto_completo => vr_des_xml
                                      ,pr_texto_novo     =>'<total>'||vr_qtdtotreg||'</total></agencia>');              
             
             vr_pa_proximo := FALSE;
        END IF;                           
     

      END LOOP;--Fim seguros a vencer -> cr_crapseg  
       
       IF vr_pa_anterior > 0 AND  vr_pa_proximo = TRUE THEN
            -- Adiciona a linha ao XML 
            gene0002.pc_escreve_xml(pr_xml    => vr_xml_clobxml 
                           ,pr_texto_completo => vr_des_xml
                           ,pr_texto_novo     =>'<total>'||vr_qtdtotreg||'</total></agencia>'); 
           
       END IF;
    
      -- Adiciona a linha ao XML 
       gene0002.pc_escreve_xml(pr_xml         => vr_xml_clobxml 
                               ,pr_texto_completo => vr_des_xml
                               ,pr_texto_novo     =>'</crrl213>'
                               ,pr_fecha_xml => TRUE);
      
      -- Verifica se ocorreram erros na geração do XML
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := vr_xml_des_erro;
        -- Gerar exceção
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/Coop
                                          ,pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nmsubdir => 'rl'); 
      --  Salvar copia relatorio para "/rlnsv"
      vr_dsdireto_rlnsv:= gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                               ,pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nmsubdir => 'rlnsv');
      
      
      -- Submeter o relatório 213
      gene0002.pc_solicita_relato(pr_cdcooper  => rw_crapcop.cdcooper                  --> Cooperativa conectada
                                 ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                 ,pr_dsxml     => vr_xml_clobxml                       --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/crrl213/agencia'                   --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl213.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => NULL                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_dsdireto||'/crrl213.lst'          --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 234 colunas
                                 ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => 'col'                                --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                 ,pr_cdrelato  => '213'                               --> Código fixo para o relatório (nao busca pelo sqcabrel)
                                 ,pr_dspathcop => vr_dsdireto_rlnsv                    --> Enviar para o rlnsv
                                 ,pr_des_erro  => vr_dscritic);                        --> Saída com erro

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_xml_clobxml);
      dbms_lob.freetemporary(vr_xml_clobxml);
      
      -- Verifica se ocorreram erros na geração do XML
      IF vr_dscritic IS NOT NULL THEN
        vr_dscritic := vr_xml_des_erro;
        -- Gerar exceção
        RAISE vr_exc_saida;
      ELSE
        -- Processo OK, devemos chamar a fimprg
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_stprogra => pr_stprogra);
        -- Salvar informações atualizadas
        COMMIT;
      END IF;
     
     EXCEPTION
      
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')|| ' - '
                                                                      || vr_cdprogra || ' --> '
                                                                      || vr_dscritic );
        END IF;

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
        pr_dscritic := SQLERRM;
        -- Efetuar rollback
        ROLLBACK;
     
     END;
END pc_crps263;
/

