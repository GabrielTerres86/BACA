CREATE OR REPLACE PROCEDURE CECRED.pc_crps457(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2)  IS
/* ..........................................................................

   Programa: pc_crps457 - Antigo Fontes/crps457.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Felipe Oliveira
   Data    : Fevereiro/2015                   Ultima atualizacao: 12/05/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 86.
               Lista Estornos de Caixa (430).

   Alteracoes: 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
   
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                
               07/01/2009 - Alterado formato do campo VALOR (Gabriel).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               09/02/2015 - Convertido para PL-SQL (pc_crps457) (Felipe)
               
               12/05/2015 - #269728 Inclusão dos comentários do fonte crps457 (Carlos)
   
-----------------------------------------------------------------------------*/
BEGIN
  DECLARE
  
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE; 
    
    -- Nome Diretorio
    vr_nom_direto VARCHAR(100);
    
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS457';
    
    vr_des_xml    CLOB;
    vr_dstexto    VARCHAR(32600) := NULL;
  
    vr_aux_cdhistor VARCHAR2(6);
    vr_aux_dshistor VARCHAR2(200);

    vr_possui_registro BOOLEAN;
  
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR(4000);
  
    CURSOR cr_crapaut(pr_cdcooper IN crapcop.cdcooper%TYPE,
                      pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT aut.dtmvtolt,
       aut.cdagenci,
       aut.nrdcaixa,
       aut.nrsequen,
       aut.cdopecxa,
       aut.cdhistor,
       aut.nrseqaut,
       aut.vldocmto,
       ope.nmoperad,
       COUNT(aut.cdagenci) OVER (PARTITION BY aut.cdagenci) total, 
       NVL(his.dshistor,' ') dshistor_his
      FROM crapaut aut,
           crapope ope,
           craphis his
      WHERE aut.cdcooper = ope.cdcooper AND
            aut.cdopecxa = ope.cdoperad AND
            aut.nrseqaut > 0            AND
            aut.dtmvtolt = pr_dtmvtolt  AND
            aut.cdcooper = ope.cdcooper AND
            ope.cdcooper = pr_cdcooper  AND
            his.cdhistor (+) = aut.cdhistor AND
            his.cdcooper (+) = aut.cdcooper
      GROUP BY aut.dtmvtolt,
               aut.cdagenci,
               aut.nrdcaixa,
               aut.nrsequen,
               aut.cdopecxa,
               aut.cdhistor,
               aut.nrseqaut,
               aut.vldocmto,
               ope.nmoperad,
               his.dshistor
    ORDER BY aut.cdagenci;
  
    -- Controle Escrita Nó
    vr_controle INTEGER  :=0;
    vr_no_aberto BOOLEAN :=FALSE;
    
  BEGIN
    
    --------------- VALIDACOES INICIAIS -----------------
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);
                              
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
  
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?>'
                           || '<Dados><registro>'); 
                           
    vr_possui_registro := FALSE;                       
     
    -- Leitura Estornos de Caixa                         
    FOR rw_crapaut IN cr_crapaut(pr_cdcooper, rw_crapdat.dtmvtolt) LOOP
      
      -- Variavel de Controle se Possui Registros 
      vr_possui_registro := TRUE; 
    
      -- Limpeza das variaveis de hsitorico.
      vr_aux_cdhistor := ' ';
      vr_aux_dshistor := ' ';
    
      -- Verifica se encontrou o descritivo do historico
      IF rw_crapaut.dshistor_his <> ' ' THEN   
        vr_aux_cdhistor := rw_crapaut.cdhistor;
        vr_aux_dshistor := rw_crapaut.dshistor_his;
      END IF;
      
      -- Controla escrita do nó <pa> no XML
      IF vr_no_aberto = FALSE AND
         vr_controle <> rw_crapaut.total THEN
         
        vr_no_aberto := TRUE;
        
        -- Escreve no Arquivo
        gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                               ,pr_texto_completo => vr_dstexto
                               ,pr_texto_novo     => '<pa>'
                               || '<cdagenci>'||rw_crapaut.cdagenci||'</cdagenci>'); 
                            
      END IF;
           
        
      vr_controle := vr_controle + 1;           
     
      -- Escreve no Arquivo    
      gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '<info>'
                             || '<nrdcaixa>' || rw_crapaut.nrdcaixa ||'</nrdcaixa>'
                             || '<nrsequen>' || gene0002.fn_mask(rw_crapaut.nrsequen,'zz.zzzz') ||'</nrsequen>'
                             || '<nrseqaut>' || gene0002.fn_mask(rw_crapaut.nrseqaut,'zz.zzzz') ||'</nrseqaut>'
                             || '<vldocmto>' || to_char(rw_crapaut.vldocmto,'999G999G990D00') ||'</vldocmto>'
                             || '<aux_historic>' || gene0002.fn_mask(vr_aux_cdhistor,'9999') || '-' || vr_aux_dshistor ||'</aux_historic>'
                             || '<aux_dsoperad>' || rw_crapaut.cdopecxa || '-' || rw_crapaut.nmoperad ||'</aux_dsoperad>'
                             || '</info>');
                              
                      
     IF vr_controle = rw_crapaut.total THEN 
       -- Escreve no Arquivo
       gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                              ,pr_texto_completo => vr_dstexto
                              ,pr_texto_novo     => '</pa>');
       vr_no_aberto := FALSE;
       vr_controle :=0;                     
     END IF;                         
                       
    
    END LOOP;
    
    IF vr_possui_registro = FALSE THEN      
      -- Escreve no Arquivo
        gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                               ,pr_texto_completo => vr_dstexto
                               ,pr_texto_novo     => '<pa></pa>');
    END IF; 
    
    -- Escreve no Arquivo
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</registro>');
    
    -- Escreve e Fecha arquivo XML
    gene0002.pc_escreve_xml(pr_xml            => vr_des_xml
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</Dados>'
                           ,pr_fecha_xml      => TRUE);
  
    -- Busca do diretório base da cooperativa para PDF
    vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  
    -- Solicita geração do relatorio
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,           --> Programa chamador
                              pr_dtmvtolt  => rw_crapdat.dtmvtolt,   --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,            --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/Dados/registro/pa',  --> Nó base do XML para leitura dos dados
                              pr_dsjasper  =>'crrl457.jasper',       --> Arquivo de layout do iReport
                              pr_dsparams  => NULL,
                              pr_dsarqsaid => vr_nom_direto||'/'||'crrl430.lst', --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_sqcabrel  => 1,
                              pr_flg_impri => 'S',    --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => NULL,   --> Nome do formulário para impressão
                              pr_nrcopias  => 1,      --> Número de cópias para impressão
                              pr_des_erro  => vr_dscritic);        --> Saída com erro    
    
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;
    
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

END pc_crps457;
/

