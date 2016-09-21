CREATE OR REPLACE PROCEDURE CECRED.pc_crps319(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                       pr_flgresta IN PLS_INTEGER,
                                       pr_stprogra OUT PLS_INTEGER,
                                       pr_infimsol OUT PLS_INTEGER,
                                       pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                       pr_dscritic OUT VARCHAR2) IS
BEGIN
  /* .............................................................................
  
     Programa: pc_crps319   (Antigo fontes/crps319.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Felipe
     Data    : Fevereiro/2015                      Ultima atualizacao: 18/02/2015
    
     Dados referentes ao programa:
  
     Frequencia: Mensal
     Objetivo  : Gerar relatorio de estatisticas de contulta de CPF's
     Solicitacao : 4
     Ordem do programa na solicitacao = 1.
     Exclusividade = 2
     Relatorio 271.
  
     Alteracoes: 
  */

  DECLARE
  
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;       
  
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE) IS
      SELECT ass.cdcooper,
             ass.cdsitcpf,
             ass.cdagenci,
             age.nmresage,
             (SELECT COUNT(1)
              FROM crapass
              WHERE ass.cdsitcpf = crapass.cdsitcpf AND
                    crapass.cdagenci = ass.cdagenci AND
                    crapass.cdcooper = ass.cdcooper AND
                    crapass.dtdemiss IS NULL) total,
             (SELECT COUNT(1)
              FROM crapass
              WHERE crapass.cdagenci = ass.cdagenci AND
                    crapass.cdcooper = ass.cdcooper AND
                    crapass.dtdemiss IS NULL) totalgeral
      FROM crapass ass,
           crapage age
      WHERE ass.cdagenci = age.cdagenci AND
            ass.cdcooper = age.cdcooper AND
            ass.cdcooper = pr_cdcooper AND
            ass.dtdemiss IS NULL
      GROUP BY ass.cdagenci,
               age.nmresage,
               ass.cdsitcpf,
               ass.cdcooper
      ORDER BY ass.cdagenci,
               ass.cdsitcpf;
               
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS319';           
  
    vr_des_xml  CLOB;
    vr_dstexto  VARCHAR(32600) := NULL;
    
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    
   
    TYPE type_pas IS RECORD(
     numero_pa   NUMBER := 0,
     nmresage   crapage.nmresage%TYPE,
     qtdconsultado NUMBER :=0,
     prcconsultado VARCHAR(10):='0,00%',
     qtdregular    NUMBER :=0,
     prcregular    VARCHAR(10):='0,00%',
     qtdpendente   NUMBER :=0,
     prcpendente   VARCHAR(10):='0,00%', 
     qtdcancelado  NUMBER :=0,
     prccancelado  VARCHAR(10):='0,00%',
     qtdirregular  NUMBER :=0,
     prcirregular  VARCHAR(10):='0,00%',
     total         NUMBER :=0);
   TYPE typ_arr_pas IS TABLE OF type_pas INDEX BY BINARY_INTEGER;

   vr_mes STRING(20);

   vr_info_pa  typ_arr_pas;
   vr_porcentagem VARCHAR(10);
   vr_indice PLS_INTEGER;
   
   
   vr_nom_direto VARCHAR(80);
   vr_dtmvtolt   crapdat.dtmvtolt%TYPE;
   vr_dscritic   VARCHAR(300);
   
   -- Quantidade Total
   vr_total_qtdconsul NUMBER :=0;
   vr_total_qtdregula NUMBER :=0;
   vr_total_qtdpenden NUMBER :=0;
   vr_total_qtdcancel NUMBER :=0;
   vr_total_qtirregul NUMBER :=0;   
   vr_total_geral     NUMBER :=0;  
   
   -- Porcentagem
   vr_prc_total_qtdconsul VARCHAR(10) :='0,00%';
   vr_prc_total_qtdregula VARCHAR(10) :='0,00%';
   vr_prc_total_qtdpenden VARCHAR(10) :='0,00%';
   vr_prc_total_qtdcancel VARCHAR(10) :='0,00%';
   vr_prc_total_qtirregul VARCHAR(10) :='0,00%'; 
    
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);
    
    -- Leitura do calendário da cooperativa
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    vr_dtmvtolt := rw_crapdat.dtmvtolt;
    vr_mes:=  TRIM(Upper(to_char(vr_dtmvtolt,'Month/YYYY')));
  
    FOR rw_crapass IN cr_crapass(pr_cdcooper) LOOP
   
      vr_porcentagem := (to_char(((rw_crapass.total / rw_crapass.totalgeral) * 100),'fm990D00')||' %');

      vr_info_pa(rw_crapass.cdagenci).numero_pa := rw_crapass.cdagenci; 
      vr_info_pa(rw_crapass.cdagenci).nmresage  := rw_crapass.nmresage; 
      vr_info_pa(rw_crapass.cdagenci).total     := rw_crapass.totalgeral;   
      
      CASE rw_crapass.cdsitcpf
        WHEN 0 THEN vr_info_pa(rw_crapass.cdagenci).qtdconsultado := rw_crapass.total;
                    vr_info_pa(rw_crapass.cdagenci).prcconsultado := vr_porcentagem;
        WHEN 1 THEN vr_info_pa(rw_crapass.cdagenci).qtdregular := rw_crapass.total;
                    vr_info_pa(rw_crapass.cdagenci).prcregular := vr_porcentagem;
        WHEN 2 THEN vr_info_pa(rw_crapass.cdagenci).qtdpendente := rw_crapass.total;
                    vr_info_pa(rw_crapass.cdagenci).prcpendente := vr_porcentagem;
        WHEN 3 THEN vr_info_pa(rw_crapass.cdagenci).qtdcancelado := rw_crapass.total;
                    vr_info_pa(rw_crapass.cdagenci).prccancelado := vr_porcentagem;
        WHEN 4 THEN vr_info_pa(rw_crapass.cdagenci).qtdirregular := rw_crapass.total;
                    vr_info_pa(rw_crapass.cdagenci).prcirregular := vr_porcentagem;
        ELSE  NULL;
      END CASE;
      
    END LOOP;
    
    -- Monta XML
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><Dados><registro>');
  
    vr_indice := vr_info_pa.first;
    WHILE vr_indice IS NOT NULL LOOP
      
      gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '<pa>'    
                             || '<cdagenci>'      ||vr_info_pa(vr_indice).numero_pa   ||'</cdagenci>'                   
                             || '<nmresage>'      ||vr_info_pa(vr_indice).nmresage    ||'</nmresage>'
                             || '<qtdconsultado>' ||TRIM(vr_info_pa(vr_indice).qtdconsultado)  ||'</qtdconsultado>'
                             || '<prcconsultado>' ||TRIM(vr_info_pa(vr_indice).prcconsultado)  ||'</prcconsultado>'
                             || '<qtdregular>'    ||TRIM(gene0002.fn_mask(vr_info_pa(vr_indice).qtdregular,'zzz.zzz')) ||'</qtdregular>'
                             || '<prcregular>'    ||TRIM(vr_info_pa(vr_indice).prcregular)     ||'</prcregular>'
                             || '<qtdpendente>'   ||TRIM(gene0002.fn_mask(vr_info_pa(vr_indice).qtdpendente,'zzz.zzz')) ||'</qtdpendente>'
                             || '<prcpendente>'   ||TRIM(vr_info_pa(vr_indice).prcpendente) ||'</prcpendente>'
                             || '<qtdcancelado>'  ||TRIM(gene0002.fn_mask(vr_info_pa(vr_indice).qtdcancelado,'zzz.zzz')) ||'</qtdcancelado>'
                             || '<prccancelado>'  ||TRIM(vr_info_pa(vr_indice).prccancelado) ||'</prccancelado>'
                             || '<qtdirregular>'  ||TRIM(gene0002.fn_mask(vr_info_pa(vr_indice).qtdirregular,'zzz.zzz')) ||'</qtdirregular>'
                             || '<prcirregular>'  ||TRIM(vr_info_pa(vr_indice).prcirregular) ||'</prcirregular>'
                             || '<total>'         || TRIM(gene0002.fn_mask(vr_info_pa(vr_indice).total,'zzz.zzz')) ||'</total>'
                             ||'</pa>');
      
      vr_total_qtdconsul := vr_total_qtdconsul + vr_info_pa(vr_indice).qtdconsultado;
      vr_total_qtdregula := vr_total_qtdregula + vr_info_pa(vr_indice).qtdregular; 
      vr_total_qtdpenden := vr_total_qtdpenden + vr_info_pa(vr_indice).qtdpendente;
      vr_total_qtdcancel := vr_total_qtdcancel + vr_info_pa(vr_indice).qtdcancelado;
      vr_total_qtirregul := vr_total_qtirregul + vr_info_pa(vr_indice).qtdirregular;
   
      vr_total_geral     := vr_total_geral + vr_info_pa(vr_indice).total; 
    
      vr_indice := vr_info_pa.next(vr_indice);
    END LOOP;
    
    -- Calculo da Porcentagem Total
    vr_prc_total_qtdconsul := to_char(((vr_total_qtdconsul / vr_total_geral) * 100),'990D00')||' %';
    vr_prc_total_qtdregula := to_char(((vr_total_qtdregula / vr_total_geral) * 100),'990D00')||' %';
    vr_prc_total_qtdpenden := to_char(((vr_total_qtdpenden / vr_total_geral) * 100),'990D00')||' %';
    vr_prc_total_qtdcancel := to_char(((vr_total_qtdcancel / vr_total_geral) * 100),'990D00')||' %'; 
    vr_prc_total_qtirregul := to_char(((vr_total_qtirregul / vr_total_geral) * 100),'990D00')||' %'; 
    
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<mesref>'||vr_mes||'</mesref>'
                           || '<totalgeral>'||to_char(vr_total_geral,'999G999') ||'</totalgeral>'
                           || '<totalconsul>'||TRIM(gene0002.fn_mask(vr_total_qtdconsul,'zzz.zzz')) ||'</totalconsul>'
                           || '<prctotalconsul>'||vr_prc_total_qtdconsul ||'</prctotalconsul>'
                           || '<totalregul>'||TRIM(gene0002.fn_mask(vr_total_qtdregula,'zzz.zzz'))||'</totalregul>'
                           || '<prctotalregul>'||vr_prc_total_qtdregula||'</prctotalregul>'
                           || '<totalpendent>'||TRIM(gene0002.fn_mask(vr_total_qtdpenden,'zzz.zzz'))||'</totalpendent>'
                           || '<prctotalpendent>'||vr_prc_total_qtdpenden||'</prctotalpendent>'
                           || '<totalcancel>'||TRIM(gene0002.fn_mask(vr_total_qtdcancel,'zzz.zzz'))||'</totalcancel>'
                           || '<prctotalcancel>'||vr_prc_total_qtdcancel||'</prctotalcancel>'
                           || '<totalirregul>'||TRIM(gene0002.fn_mask(vr_total_qtirregul,'zzz.zzz'))||'</totalirregul>'
                           || '<prctotalirregul>'||vr_prc_total_qtirregul||'</prctotalirregul>');
  
  
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</registro>');
                           
    -- Fechar XML                       
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</Dados>'
                           ,pr_fecha_xml      => TRUE);                       
                            

    -- Busca do diretório base da cooperativa para PDF
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
    
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,          --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,          --> Programa chamador
                                pr_dtmvtolt  => vr_dtmvtolt,          --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,           --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/Dados/registro/pa', --> Nó base do XML para leitura dos dados
                                pr_dsjasper  =>'crrl319.jasper',      --> Arquivo de layout do iReport
                                pr_dsparams  => NULL,
                                pr_dsarqsaid => vr_nom_direto||'/'||'crrl271.lst', --> Arquivo final
                                pr_flg_gerar => 'N',
                                pr_qtcoluna  => 132,
                                pr_sqcabrel  => 1,
                                pr_flg_impri => 'S',    --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => NULL,   --> Nome do formulário para impressão
                                pr_nrcopias  => 1,      --> Número de cópias para impressão
                                pr_des_erro  => vr_dscritic);        --> Saída com erro 
     
     
     
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    
    --Salvar informacoes no banco de dados
    COMMIT;
    
  EXCEPTION
  WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic:= NVL(vr_cdcritic, 0);
      pr_dscritic:= vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic:= 0;
      pr_dscritic:= SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
  END;

END pc_crps319;
/

