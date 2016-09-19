CREATE OR REPLACE PACKAGE CECRED.TELA_CADCCO AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_CADCCO                         antigo: /ayllos/fontes/cadcco.p
  --  Sistema  : Rotinas genericas referente a zoom de pesquisa
  --  Sigla    : CRED
  --  Autor    : Jonathan - RKAM
  --  Data     : Marco/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Cadastro Parametros Sistema de Cobranca.

  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
    
  /* Tabela para guardar os registro atualizados */
  TYPE typ_registros IS RECORD 
    (avltarifa crapcct.vltarifa%TYPE
    ,acdtarhis crapcct.cdtarhis%TYPE
    ,nvltarifa crapcct.vltarifa%TYPE
    ,ncdtarhis crapcct.cdtarhis%TYPE);
    
  /* Tabela para guardar os registro atualizados */
  TYPE typ_tab_registros IS TABLE OF typ_registros INDEX BY PLS_INTEGER;  
    
  PROCEDURE pc_consulta(pr_nrconven  IN crapcco.nrconven%TYPE -- Convenio
                       ,pr_dsdepart  IN VARCHAR2              --Departamento
                       ,pr_cddopcao  IN VARCHAR2              --Opção
                       ,pr_nmdatela  IN VARCHAR2              --Nome da tela
                       ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                       ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                       ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                       ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                       ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                       ,pr_des_erro  OUT VARCHAR2);           --Saida OK/NOK
  
  PROCEDURE pc_alteracao(pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                        ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco
                        ,pr_nrdctabb IN crapcco.nrdctabb%TYPE --Conta base
                        ,pr_cdbccxlt IN crapcco.cdbccxlt%TYPE --Caixa/lote
                        ,pr_cdagenci IN crapcco.cdagenci%TYPE --Agencia
                        ,pr_nrdolote IN crapcco.nrdolote%TYPE --Lote
                        ,pr_cdhistor IN crapcco.cdhistor%TYPE --Histórico
                        ,pr_vlrtarif IN crapcco.vlrtarif%TYPE --Valor tarifa
                        ,pr_cdtarhis IN crapcco.cdtarhis%TYPE --Código tarifa
                        ,pr_cdhiscxa IN crapcco.cdhiscxa%TYPE --Histórico caixa
                        ,pr_vlrtarcx IN crapcco.vlrtarcx%TYPE --Valor tarifa caixa
                        ,pr_cdhisnet IN crapcco.cdhisnet%TYPE --Histórico internet
                        ,pr_vlrtarnt IN crapcco.vlrtarnt%TYPE --Valor tarifa internet
                        ,pr_cdhistaa IN crapcco.cdhistaa%TYPE --Histórico TAA
                        ,pr_vltrftaa IN crapcco.vltrftaa%TYPE --Vaor tarifa TAA
                        ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                        ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                        ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                        ,pr_vlrtrblq IN crapcco.vlrtrblq%TYPE --Valor tarifa bloqueto
                        ,pr_cdhisblq IN crapcco.cdhisblq%TYPE --Histórico bloqueto
                        ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                        ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                        ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                        ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                        ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                        ,pr_flgutceb IN crapcco.flgutceb%TYPE --Utiliza CEB
                        ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                        ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
                        ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                        ,pr_dtmvtolt IN VARCHAR2              --Data de movimento
                        ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
                        ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Qtd dias float                      
                        ,pr_dsdepart IN VARCHAR2              --Departamento
                        ,pr_cddopcao IN VARCHAR2              --Opção da tela
                        ,pr_nmdatela IN VARCHAR2              --Nome da tela                        
                        ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                        
  PROCEDURE pc_exclusao (pr_nrconven  IN crapcco.nrconven%TYPE   --Convenio
                        ,pr_dtmvtolt  IN VARCHAR2                --Data de movimento 
                        ,pr_cddopcao  IN VARCHAR                 --Opção
                        ,pr_dsdepart  IN VARCHAR                 --Departamento
                        ,pr_nmdatela  IN VARCHAR2                --Nome da tela
                        ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                        ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                        ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                        ,pr_des_erro  OUT VARCHAR2);             --Saida OK/NOK                      
                        
   
  PROCEDURE pc_inclusao (pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                        ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco
                        ,pr_nrdctabb IN crapcco.nrdctabb%TYPE --Conta base
                        ,pr_cdbccxlt IN crapcco.cdbccxlt%TYPE --Caixa/lote
                        ,pr_cdagenci IN crapcco.cdagenci%TYPE --Agencia
                        ,pr_nrdolote IN crapcco.nrdolote%TYPE --Lote
                        ,pr_cdhistor IN crapcco.cdhistor%TYPE --Histórico
                        ,pr_vlrtarif IN crapcco.vlrtarif%TYPE --Valor tarifa
                        ,pr_cdtarhis IN crapcco.cdtarhis%TYPE --Código tarifa
                        ,pr_cdhiscxa IN crapcco.cdhiscxa%TYPE --Histórico caixa
                        ,pr_vlrtarcx IN crapcco.vlrtarcx%TYPE --Valor tarifa caixa
                        ,pr_cdhisnet IN crapcco.cdhisnet%TYPE --Histórico internet
                        ,pr_vlrtarnt IN crapcco.vlrtarnt%TYPE --Valor tarifa internet
                        ,pr_cdhistaa IN crapcco.cdhistaa%TYPE --Histórico TAA
                        ,pr_vltrftaa IN crapcco.vltrftaa%TYPE --Vaor tarifa TAA
                        ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                        ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                        ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                        ,pr_vlrtrblq IN crapcco.vlrtrblq%TYPE --Valor tarifa bloqueto
                        ,pr_cdhisblq IN crapcco.cdhisblq%TYPE --Histórico bloqueto
                        ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                        ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                        ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                        ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                        ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                        ,pr_flgutceb IN crapcco.flgutceb%TYPE --Utiliza CEB
                        ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                        ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
                        ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                        ,pr_dtmvtolt IN VARCHAR2              --Data de movimento                        
                        ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
                        ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Qtd dias float                      
                        ,pr_dsdepart IN VARCHAR2              --Departamento
                        ,pr_cddopcao IN VARCHAR2              --Opção da tela
                        ,pr_nmdatela IN VARCHAR2              --Nome da tela                        
                        ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
   
  PROCEDURE pc_consulta_tarifas(pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                               ,pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco                              
                               ,pr_dsdepart IN VARCHAR2              --Departamento
                               ,pr_cddopcao IN VARCHAR2              --Opção
                               ,pr_nmdatela IN VARCHAR2              --Nome da tela
                               ,pr_nrregist IN INTEGER               -- Número de registros
                               ,pr_nriniseq IN INTEGER               -- Número sequencial 
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                               
  PROCEDURE pc_consulta_motivos(pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_nrconven IN crapcct.nrconven%TYPE --Convenio
                               ,pr_cddbanco IN crapcct.cddbanco%TYPE --Banco
                               ,pr_cdocorre IN crapcct.cdocorre%TYPE --Ocorrencia                               
                               ,pr_dsdepart IN VARCHAR2              --Departamento
                               ,pr_cddopcao IN VARCHAR2              --Opção
                               ,pr_nmdatela IN VARCHAR2              --Nome da tela
                               ,pr_nrregist IN INTEGER               -- Número de registros
                               ,pr_nriniseq IN INTEGER               -- Número sequencial 
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK    
  
  PROCEDURE pc_atualiza_motivos(pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_nrconven IN crapctm.nrconven%TYPE --Convenio
                               ,pr_dsdepart IN VARCHAR2              --Departamento
                               ,pr_cddopcao IN VARCHAR2              --Opção
                               ,pr_nmdatela IN VARCHAR2              --Nome da tela
                               ,pr_vlmotivo IN VARCHAR2              --Motivos
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                                                           
  PROCEDURE pc_atualiza_tarifas(pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_nrconven IN crapctm.nrconven%TYPE --Convenio
                               ,pr_vltarifa IN VARCHAR2              --Tarifas
                               ,pr_dsdepart IN VARCHAR2              --Departamento
                               ,pr_cddopcao IN VARCHAR2              --Opção
                               ,pr_nmdatela IN VARCHAR2              --Nome da tela
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                                                                                          
END TELA_CADCCO;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADCCO AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_CADCCO                          antigo: /ayllos/fontes/cadcco.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Jonathan - RKAM
   Data    : Marco/2016                       Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cadastro Parametros Sistema de Cobranca.

   Alteracoes:                                          
  ---------------------------------------------------------------------------------------------------------------*/
  
  FUNCTION fn_nmoperador(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdoperad IN crapope.cdoperad%TYPE) RETURN VARCHAR2 IS  
                        
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : fn_nmoperador                            antiga: proc_nmoperad
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Funcao para retornar o nome do operador.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                            
      
   --Cursor para encontrar o operador                   
   CURSOR cr_crapope IS
   SELECT crapope.nmoperad
     FROM crapope 
    WHERE crapope.cdcooper = pr_cdcooper   
      AND crapope.cdoperad = pr_cdoperad;
   rw_crapope cr_crapope%ROWTYPE;
  
   BEGIN
     OPEN cr_crapope;
     
     FETCH cr_crapope INTO rw_crapope;
     
     CLOSE cr_crapope;
     
     RETURN TRIM(rw_crapope.nmoperad);
     
   END fn_nmoperador; 
  
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_tipdolog IN INTEGER 
                       ,pr_nrconven IN crapcco.nrconven%TYPE
                       ,pr_dsdcampo IN VARCHAR2
                       ,pr_vlrcampo IN VARCHAR2
                       ,pr_vlcampo2 IN VARCHAR2
                       ,pr_des_erro OUT VARCHAR2) IS  
                        
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gera_log                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para gerar log
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                            
   
   BEGIN
     
     CASE pr_tipdolog
       WHEN 1 THEN
         -- Gera log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => 'cadcco.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                        'Incluiu o convenio de cobranca ' || 
                                                        pr_nrconven || '.');
       
       WHEN 2 THEN
         -- Gera log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_nmarqlog     => 'cadcco.log'
                                   ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                      'Alterou o convenio de cobranca ' || 
                                                      pr_nrconven || ', campo ' || pr_dsdcampo || 
                                                      ' de ' || pr_vlrcampo || ' para ' || pr_vlcampo2 || '.');
       
       WHEN 3 THEN
         -- Gera log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_nmarqlog     => 'cadcco.log'
                                   ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                       'Excluiu o convenio de cobranca ' || 
                                                       pr_nrconven || '.');
       WHEN 4 THEN
         -- Gera log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_nmarqlog     => 'cadcco.log'
                                   ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                       'Alterou a tarifa do motivo de cobranca do convenio ' || 
                                                       pr_nrconven || ', campo ' || pr_dsdcampo || 
                                                      ' de ' || pr_vlrcampo || ' para ' || pr_vlcampo2 || '.');
       WHEN 5 THEN
         -- Gera log
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_nmarqlog     => 'cadcco.log'
                                   ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                       ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                       'Alterou a tarifa de cobranca do convenio ' || 
                                                       pr_nrconven || ', campo ' || pr_dsdcampo || 
                                                      ' de ' || pr_vlrcampo || ' para ' || pr_vlcampo2 || '.');
                                                                                                                                                                                                    
       ELSE NULL;
       
     END CASE; 
        
     pr_des_erro := 'OK';                                          
   
   EXCEPTION
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';    
         
   END pc_gera_log;    
   
   PROCEDURE pc_valida_informacoes(pr_cdcooper IN crapcop.cdcooper%TYPE --Código da cooperativa
                                  ,pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                                  ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco
                                  ,pr_nrdctabb IN crapcco.nrdctabb%TYPE --Conta base
                                  ,pr_cdbccxlt IN crapcco.cdbccxlt%TYPE --Caixa/lote
                                  ,pr_cdagenci IN crapcco.cdagenci%TYPE --Agencia
                                  ,pr_nrdolote IN crapcco.nrdolote%TYPE --Lote
                                  ,pr_cdhistor IN crapcco.cdhistor%TYPE --Histórico
                                  ,pr_vlrtarif IN crapcco.vlrtarif%TYPE --Valor tarifa
                                  ,pr_cdtarhis IN crapcco.cdtarhis%TYPE --Código tarifa
                                  ,pr_cdhiscxa IN crapcco.cdhiscxa%TYPE --Histórico caixa
                                  ,pr_vlrtarcx IN crapcco.vlrtarcx%TYPE --Valor tarifa caixa
                                  ,pr_cdhisnet IN crapcco.cdhisnet%TYPE --Histórico internet
                                  ,pr_vlrtarnt IN crapcco.vlrtarnt%TYPE --Valor tarifa internet
                                  ,pr_cdhistaa IN crapcco.cdhistaa%TYPE --Histórico TAA
                                  ,pr_vltrftaa IN crapcco.vltrftaa%TYPE --Vaor tarifa TAA
                                  ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                                  ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                                  ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                                  ,pr_vlrtrblq IN crapcco.vlrtrblq%TYPE --Valor tarifa bloqueto
                                  ,pr_cdhisblq IN crapcco.cdhisblq%TYPE --Histórico bloqueto
                                  ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                                  ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                                  ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                                  ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                                  ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                                  ,pr_flgutceb IN crapcco.flgutceb%TYPE --Utiliza CEB
                                  ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                                  ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
                                  ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                                  ,pr_dtmvtolt VARCHAR2                 --Data de movimento                       
                                  ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
                                  ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Qtd dias float                      
                                  ,pr_dsdepart IN VARCHAR2              --Departamento
                                  ,pr_cddopcao IN VARCHAR2              --Opção da tela
                                  ,pr_nmdatela IN VARCHAR2              --Nome da tela                          
                                  ,pr_nmdbanco OUT crapcco.nmdbanco%TYPE--Nome do banco 
                                  ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --Descrição da crítica                                  
                                  ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_valida_informacoes                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza a validação das informações para cadastro/alteração do registro de convenio
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
    
    --Cursor para encontrar o convenio
    CURSOR cr_crapcco(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrconven IN crapcco.nrconven%TYPE)IS
    SELECT crapcco.cdcooper
      FROM crapcco 
     WHERE crapcco.cdcooper = pr_cdcooper
       AND crapcco.nrconven = pr_nrconven;
    rw_crapcco cr_crapcco%ROWTYPE;
    
    --Cursor para encontrar o banco
    CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE)IS
    SELECT crapban.cdbccxlt
          ,crapban.nmresbcc
      FROM crapban
     WHERE crapban.cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;  
    
    --Cursor para encontrar o histórico 
    CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE
                     ,pr_cdhistor IN craphis.cdhistor%TYPE)IS
    SELECT craphis.cdcooper
      FROM craphis
     WHERE craphis.cdcooper = pr_cdcooper
       AND craphis.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%ROWTYPE;  
    
    --Cursor para encontrar a agencia
    CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                     ,pr_cdagenci IN crapage.cdagenci%TYPE)IS
    SELECT crapage.cdcooper
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;  
    
    --Cursor para encontrar o banco/caixa
    CURSOR cr_crapbcl(pr_cdbccxlt IN crapbcl.cdbccxlt%TYPE)IS
    SELECT crapbcl.cdbccxlt
      FROM crapbcl
     WHERE crapbcl.cdbccxlt = pr_cdbccxlt;
    rw_crapbcl cr_crapbcl%ROWTYPE;    
    
    --Cursor para encontra se já exite um convenio para internet
    CURSOR cr_crapcco_internet(pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_nrconven IN crapcco.nrconven%TYPE
                              ,pr_flgregis IN crapcco.flgregis%TYPE
                              ,pr_cddbanco IN crapcco.cddbanco%TYPE) IS
    SELECT crapcco.nrconven
      FROM crapcco
     WHERE crapcco.cdcooper = pr_cdcooper
       AND crapcco.nrconven <> pr_nrconven
       AND crapcco.flgativo = 1
       AND crapcco.flgregis = pr_flgregis
       AND crapcco.flginter = 1 
       AND crapcco.cddbanco = pr_cddbanco
       AND crapcco.dsorgarq = 'INTERNET';
    rw_crapcco_internet cr_crapcco_internet%ROWTYPE;
    
    --Cursor para encontra se já exite um convenio para empréstimo
    CURSOR cr_crapcco_empr(pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_dsorgarq IN crapcco.dsorgarq%TYPE) IS
    SELECT crapcco.nrconven
      FROM crapcco
     WHERE crapcco.cdcooper = pr_cdcooper       
       AND crapcco.dsorgarq = pr_dsorgarq
       AND crapcco.flgativo = 1;
    rw_crapcco_empr cr_crapcco_empr%ROWTYPE;    
       
    --Cursor para verificar se existe um boleto ativo para o convenio em questão
    CURSOR cr_crapcob(pr_cdcooper IN crapcop.cdcooper%TYPE  
                     ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE) IS
    SELECT crapcob.cdcooper
      FROM crapcob
     WHERE crapcob.cdcooper = pr_cdcooper
       AND crapcob.nrcnvcob = pr_nrcnvcob
       AND crapcob.incobran = 0
       AND crapcob.dtdpagto IS NULL
       AND crapcob.dtdbaixa IS NOT NULL 
       AND crapcob.dtelimin IS NOT NULL;      
    rw_crapcob cr_crapcob%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
        
    IF pr_dsdepart <> 'TI' AND
       pr_dsdepart <> 'SUPORTE' THEN 
       
      vr_cdcritic := 36; 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           
      RAISE vr_exc_erro;
      
    END IF;
    
    IF pr_cddopcao = 'I' THEN 
      
      IF pr_nrconven IS NULL THEN
        
        --Monta mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Codigo do convenio nao informado.';
                     
        RAISE vr_exc_erro;
        
      END IF;
      
      OPEN cr_crapcco(pr_cdcooper => pr_cdcooper
                     ,pr_nrconven => pr_nrconven);
      
      FETCH cr_crapcco INTO rw_crapcco;
      
      IF cr_crapcco%FOUND THEN
        
        --Fecha o cursor
        CLOSE cr_crapcco;
      
        --Monta mensagem de erro     
        vr_cdcritic := 793;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        RAISE vr_exc_erro;
        
      END IF;
       
      --Fecha o cursor
      CLOSE cr_crapcco; 
      
    ELSIF pr_cddopcao = 'A' AND 
          pr_flgativo = 1   THEN
      
      OPEN cr_crapcob(pr_cdcooper => pr_cdcooper
                     ,pr_nrcnvcob => pr_nrconven);
                       
      FETCH cr_crapcob INTO rw_crapcob;
        
      IF cr_crapcob%FOUND THEN
          
        CLOSE cr_crapcob;
        
        --Monta mensagem de erro     
        vr_cdcritic := 0;
        vr_dscritic := 'Ha bolet(s) ativo(s) para este convenio!';
        
        RAISE vr_exc_erro;
        
      END IF;
        
      CLOSE cr_crapcob; 
      
    END IF;
    
    --Valida a situação
    IF pr_flgativo <> 0 AND
       pr_flgativo <> 1 THEN
     
      vr_cdcritic := 0;      
      vr_dscritic := 'Situacao invalida.';
      RAISE vr_exc_erro;      
       
    END IF;
    
    --Valida a origem do arquivo
    IF trim(pr_dsorgarq) IS NULL THEN
     
      vr_cdcritic := 0;      
      vr_dscritic := 'Origem invalida.';
      RAISE vr_exc_erro;      
       
    END IF;
    
    --Valida conta base
    IF nvl(pr_nrdctabb,0) = 0 THEN
    
      vr_cdcritic := 127;  
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      pr_nmdcampo := 'nrdctabb';
      
      RAISE vr_exc_erro;  
    
    END IF;
    
    --Valida tipo de cobrança
    IF pr_flgregis <> 0 AND
       pr_flgregis <> 1 THEN
    
      vr_cdcritic := 0;      
      vr_Dscritic := 'Tipo de cobranca nao informado.';      
      pr_nmdcampo := 'flgregis';
      
      RAISE vr_exc_erro;  
    
    END IF; 
    
    --Verifica se banco existe
    OPEN cr_crapban(pr_cdbccxlt => pr_cddbanco);   
      
    FETCH cr_crapban INTO rw_crapban;
    
    IF cr_crapban%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_crapban; 
      
      vr_cdcritic := 57;  
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);  
      pr_nmdcampo := 'cddbanco';
            
      RAISE vr_exc_erro;
    
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapban;
      
      pr_nmdbanco := rw_crapban.nmresbcc;
      
    END IF;    
    
    --Verifica se baco/caixa existe
    OPEN cr_crapbcl(pr_cdbccxlt => pr_cdbccxlt);                   
      
    FETCH cr_crapbcl INTO rw_crapbcl;
    
    IF cr_crapbcl%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_crapbcl; 
      
      vr_cdcritic := 57;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);    
      pr_nmdcampo := 'cdbccxlt';
            
      RAISE vr_exc_erro;
    
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapbcl;
      
    END IF;
    
    --Verifica se agencia existe
    OPEN cr_crapage(pr_cdcooper => pr_cdcooper
                   ,pr_cdagenci => pr_cdagenci);                   
      
    FETCH cr_crapage INTO rw_crapage;
    
    IF cr_crapage%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_crapage; 
      
      vr_cdcritic := 962;  
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);   
      pr_nmdcampo := 'cdagenci';
           
      RAISE vr_exc_erro;
    
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapage;
      
    END IF;
    
    --Valida número do lote
    IF nvl(pr_nrdolote,0) = 0 THEN
    
      vr_cdcritic := 58;  
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);  
      pr_nmdcampo := 'nrdolote';
            
      RAISE vr_exc_erro;  
    
    END IF; 
    
    --Verifica se histórico existe
    OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                   ,pr_cdhistor => pr_cdhistor);                   
      
    FETCH cr_craphis INTO rw_craphis;
    
    IF cr_craphis%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_craphis; 
      
      vr_cdcritic := 93; 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      pr_nmdcampo := 'cdhistor';
               
      RAISE vr_exc_erro;
    
    ELSE
      
      --Fecha o cursor
      CLOSE cr_craphis;
      
    END IF;
    
    --Valida integração Serasa
    IF pr_flserasa <> 0 AND
       pr_flserasa <> 1 THEN
       
      vr_cdcritic := 0;
      vr_dscritic := 'Integracao Serasa nao informado.'; 
      pr_nmdcampo := 'flserasa';
           
      RAISE vr_exc_erro; 
       
    END IF;
    
    --Valida nome do arquivo
    IF TRIM(pr_nmarquiv) IS NULL THEN
      
      vr_cdcritic := 182;  
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);    
      pr_nmdcampo := 'nmarquiv';
          
      RAISE vr_exc_erro; 
      
    END IF;
    
    --Valida utiliza CoopCob
    IF pr_flcopcob <> 0 AND
       pr_flcopcob <> 1 THEN
       
      vr_cdcritic := 0;
      vr_dscritic := 'Utiliza CoopCob nao informado.';
      pr_nmdcampo := 'flcopcob';
            
      RAISE vr_exc_erro; 
       
    END IF;
    
    --Valida diretorio
    IF trim(pr_nmdireto) IS NULL AND 
       pr_flcopcob = 1           THEN
      
      --Monta mensagem de critica
      vr_cdcritic := 375;
      
       -- Busca critica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      pr_nmdcampo := 'nmdireto';   
         
      RAISE vr_exc_erro;       
    
    END IF;
      
    --Valida Quantidade de dias de float
    IF NOT (pr_qtdfloat >= 0 AND
       pr_qtdfloat <= 5)     THEN
      
      vr_cdcritic := 0;
      vr_dscritic := 'Quantidade de dias de Float invalido.';  
      pr_nmdcampo := 'qtdfloat';
          
      RAISE vr_exc_erro; 
      
    END IF;
    
    --Valida a sequencia
    IF NOT (pr_flgutceb >= 0 AND
       pr_flgutceb <= 1)     THEN
      
      vr_cdcritic := 0;
      vr_dscritic := 'Sequencia invalida.';   
      pr_nmdcampo := 'flgcnvcc';
         
      RAISE vr_exc_erro; 
      
    END IF;
           
    --Valida Lote tarifa boleto impresso
    IF nvl(pr_nrlotblq,0) = 0 THEN
    
      vr_cdcritic := 58; 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);  
      pr_nmdcampo := 'nrlotblq';
             
      RAISE vr_exc_erro;  
    
    END IF; 
       
    --Se não for cobrança registrada deve validar o histórico de cobrança
    IF pr_flgregis = 0 THEN
      
      --Verifica se histórico tarifa de cobrança existe
      OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                     ,pr_cdhistor => pr_cdtarhis);                   
        
      FETCH cr_craphis INTO rw_craphis;
      
      IF cr_craphis%NOTFOUND THEN
      
        --Fecha o cursor
        CLOSE cr_craphis; 
        
        vr_cdcritic := 93;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);  
        pr_nmdcampo := 'cdtarhis';
                
        RAISE vr_exc_erro;
      
      ELSE
        
        --Fecha o cursor
        CLOSE cr_craphis;
        
      END IF;
      
    END IF; 
    
    --Verifica se histórico tarifa de boleto pago Coop existe
    OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                   ,pr_cdhistor => pr_cdhiscxa);                   
      
    FETCH cr_craphis INTO rw_craphis;
    
    IF cr_craphis%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_craphis; 
      
      vr_cdcritic := 93; 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);   
      pr_nmdcampo := 'cdhiscxa';
            
      RAISE vr_exc_erro;
    
    ELSE
      
      --Fecha o cursor
      CLOSE cr_craphis;
      
    END IF;

    --Verifica se histórico tarifa de boleto pago Internet existe
    OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                   ,pr_cdhistor => pr_cdhisnet);                   
      
    FETCH cr_craphis INTO rw_craphis;
    
    IF cr_craphis%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_craphis; 
      
      vr_cdcritic := 93; 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      pr_nmdcampo := 'cdhisnet';
               
      RAISE vr_exc_erro;
    
    ELSE
      
      --Fecha o cursor
      CLOSE cr_craphis;
      
    END IF;
    
    --Verifica se histórico tarifa de boleto pago TAA existe
    OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                   ,pr_cdhistor => pr_cdhistaa);                   
      
    FETCH cr_craphis INTO rw_craphis;
    
    IF cr_craphis%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_craphis; 
      
      vr_cdcritic := 93;  
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);  
      pr_nmdcampo := 'cdhistaa';
            
      RAISE vr_exc_erro;
    
    ELSE
      
      --Fecha o cursor
      CLOSE cr_craphis;
      
    END IF;

    --Verifica se histórico tarifa de boleto pago pré-impresso existe
    OPEN cr_craphis(pr_cdcooper => pr_cdcooper
                   ,pr_cdhistor => pr_cdhisblq);                   
      
    FETCH cr_craphis INTO rw_craphis;
    
    IF cr_craphis%NOTFOUND THEN
    
      --Fecha o cursor
      CLOSE cr_craphis; 
      
      vr_cdcritic := 93;    
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);    
      pr_nmdcampo := 'cdhisblq';
        
      RAISE vr_exc_erro;
    
    ELSE
      
      --Fecha o cursor
      CLOSE cr_craphis;
      
    END IF;
    
    --Se não for cobrança registrada deve validar o valor da tarifa de cobrança
    IF nvl(pr_vlrtarif,0) < 0 AND 
       pr_flgregis = 0        THEN
      
      vr_cdcritic := 0;    
      vr_dscritic := 'Nao e permitido valor negativo.';    
      pr_nmdcampo := 'vlrtarif';
        
      RAISE vr_exc_erro;
      
    END IF;
    
    IF nvl(pr_vlrtarcx,0) < 0 THEN  
      
      vr_cdcritic := 0;    
      vr_dscritic := 'Nao e permitido valor negativo.';    
      pr_nmdcampo := 'vlrtarcx';
        
      RAISE vr_exc_erro;
    
    END IF;
    
    IF nvl(pr_vlrtarnt,0) < 0 THEN
    
      vr_cdcritic := 0;    
      vr_dscritic := 'Nao e permitido valor negativo.';   
      pr_nmdcampo := 'vlrtarnt';
        
      RAISE vr_exc_erro;  
    
    END IF;
    
    IF nvl(pr_vltrftaa,0) < 0 THEN
      
      vr_cdcritic := 0;    
      vr_dscritic := 'Nao e permitido valor negativo.';
      pr_nmdcampo := 'vltrftaa';
        
      RAISE vr_exc_erro;
    
    END IF;
    
    IF nvl(pr_vlrtrblq,0) < 0 THEN
     
      vr_cdcritic := 0;    
      vr_dscritic := 'Nao e permitido valor negativo.';  
      pr_nmdcampo := 'vlrtrblq';
        
      RAISE vr_exc_erro; 
    
    END IF;
    
    IF pr_dsorgarq = 'INTERNET' AND 
       pr_cddopcao <> 'A'       THEN
      
      OPEN cr_crapcco_internet(pr_cdcooper => pr_cdcooper
                              ,pr_nrconven => pr_nrconven
                              ,pr_flgregis => pr_flgregis
                              ,pr_cddbanco => pr_cddbanco);
                                     
      FETCH cr_crapcco_internet INTO rw_crapcco_internet;
      
      IF cr_crapcco_internet%FOUND THEN
        
         --Fecha o cursor
         CLOSE cr_crapcco_internet;
         
         --Monta mensagem de erro
         vr_cdcritic := 0;
         vr_dscritic := 'Ja existe outro convenio para Internet.';
          
         RAISE vr_exc_erro;            
      
      END IF;                                
      
      CLOSE cr_crapcco_internet;
    
    END IF;
    
    IF pr_dsorgarq = 'EMPRESTIMO'THEN
      
      OPEN cr_crapcco_empr(pr_cdcooper => pr_cdcooper
                          ,pr_dsorgarq => pr_dsorgarq);
                                     
      FETCH cr_crapcco_empr INTO rw_crapcco_empr;
      
      IF cr_crapcco_empr%FOUND THEN
        
         --Fecha o cursor
         CLOSE cr_crapcco_empr;
         
         --Monta mensagem de erro
         vr_cdcritic := 0;
         vr_dscritic := 'Ja possui um convenio de EMPRESTIMO ativo cadastrado.';
          
         RAISE vr_exc_erro;                 
      
      END IF;                                
      
      CLOSE cr_crapcco_empr;
    
    END IF; 
                                                   
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
              
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_valida_informacoes --> '|| SQLERRM;
            
  END pc_valida_informacoes;                                     
  
  PROCEDURE pc_consulta (pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                        ,pr_dsdepart IN VARCHAR2              --Departamento
                        ,pr_cddopcao IN VARCHAR2              --Opção
                        ,pr_nmdatela IN VARCHAR2              --Nome da tela
                        ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_consulta                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Marco/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca cadastro de parametro de cobranca.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
  
    --Busca os parametros de cobranca
    CURSOR cr_crapcco(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrconven IN crapcco.nrconven%TYPE) IS
    SELECT crapcco.cddbanco
          ,crapcco.nrdctabb
          ,crapcco.cdoperad
          ,crapcco.nmdbanco
          ,crapcco.cdbccxlt
          ,crapcco.cdhistor
          ,crapcco.cdtarhis
          ,crapcco.vlrtarcx
          ,crapcco.vlrtarnt
          ,crapcco.vltrftaa
          ,crapcco.vlrtrblq
          ,crapcco.cdhisblq
          ,crapcco.dsorgarq
          ,crapcco.nmdireto
          ,crapcco.flgutceb
          ,crapcco.flcopcob
          ,crapcco.cdcartei
          ,crapcco.cdagenci
          ,crapcco.dtmvtolt
          ,crapcco.vlrtarif
          ,crapcco.nrdolote
          ,crapcco.cdhiscxa
          ,crapcco.cdhisnet
          ,crapcco.cdhistaa
          ,crapcco.nrlotblq
          ,crapcco.nrvarcar
          ,crapcco.nrbloque
          ,crapcco.tamannro
          ,crapcco.nmarquiv
          ,crapcco.flgativo
          ,crapcco.flgregis
          ,crapcco.qtdfloat 
          ,crapcco.flserasa       
      FROM crapcco
     WHERE crapcco.nrconven = pr_nrconven 
       AND crapcco.cdcooper = pr_cdcooper;
    rw_crapcco cr_crapcco%ROWTYPE;
      
    --Cursor para verificar se já existe algum boleto atrelado ao convenio
    CURSOR cr_crapcob(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                     ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                     ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                     ,pr_tipocons IN INTEGER) IS -- 0 - Nao verifica incobran ; 1 - Verifica incobran  
    SELECT crapcob.cdcooper
      FROM crapcob
     WHERE crapcob.cdcooper = pr_cdcooper
       AND crapcob.cdbandoc = pr_cdbandoc
       AND crapcob.nrdctabb = pr_nrdctabb
       AND crapcob.nrcnvcob = pr_nrcnvcob
       AND crapcob.nrdconta > 0
       AND crapcob.nrdocmto > 0
       AND crapcob.incobran = decode(nvl(pr_tipocons,0),0,crapcob.incobran,0);
    rw_crapcob cr_crapcob%ROWTYPE;
     
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_nmoperad crapope.nmoperad%TYPE;
    vr_exisbole INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCCO'
                              ,pr_action => null); 
    
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    OPEN cr_crapcco(pr_cdcooper => vr_cdcooper
                   ,pr_nrconven => pr_nrconven);
    
    FETCH cr_crapcco INTO rw_crapcco;
    
    IF cr_crapcco%NOTFOUND THEN
      
      CLOSE cr_crapcco;
      
      IF pr_cddopcao = 'I' THEN
      
        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
          
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><parametros existbole="'|| vr_exisbole ||'"/>'||
                                                     '</Root>'
                               ,pr_fecha_xml      => TRUE);                                    
                      
        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);
        
        pr_des_erro := 'OK';
        
        RETURN;
         
      END IF;
       
      vr_cdcritic := 563;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      
      RAISE vr_exc_erro;
      
    ELSE
      
      CLOSE cr_crapcco;
     
      IF pr_cddopcao = 'I' THEN
      
         vr_cdcritic := 793;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      
         RAISE vr_exc_erro;
         
      END IF;    
    
    END IF;
    
    IF pr_cddopcao = 'E' THEN
    
      OPEN cr_crapcob(pr_cdcooper => vr_cdcooper
                     ,pr_cdbandoc => rw_crapcco.cddbanco
                     ,pr_nrdctabb => rw_crapcco.nrdctabb
                     ,pr_nrcnvcob => pr_nrconven
                     ,pr_tipocons => 0);
                     
      FETCH cr_crapcob INTO rw_crapcob;
      
      IF cr_crapcob%FOUND THEN
        
        CLOSE cr_crapcob;
      
        vr_cdcritic := 0;
        vr_dscritic := 'Ha boleto(s) associado(s) a este convenio!';
      
        RAISE vr_exc_erro;
      
      END IF;
      
      CLOSE cr_crapcob;
    
    ELSIF pr_cddopcao = 'I' OR 
          pr_cddopcao = 'A' THEN
      
      OPEN cr_crapcob(pr_cdcooper => vr_cdcooper
                     ,pr_cdbandoc => rw_crapcco.cddbanco
                     ,pr_nrdctabb => rw_crapcco.nrdctabb
                     ,pr_nrcnvcob => pr_nrconven
                     ,pr_tipocons => 1);
                     
      FETCH cr_crapcob INTO rw_crapcob;
      
      IF cr_crapcob%FOUND THEN            
      
        vr_exisbole := 1;
      
      END IF;
      
      CLOSE cr_crapcob;
     
    END IF;    
              
    vr_nmoperad := fn_nmoperador(pr_cdcooper => vr_cdcooper
                                ,pr_cdoperad => rw_crapcco.cdoperad);
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><parametros existbole="'|| vr_exisbole ||'">');                                    
                                    
    -- Carrega os dados           
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<parametro>'||                                                       
                                                 '  <cddbanco>' || rw_crapcco.cddbanco||'</cddbanco>'||
                                                 '  <nrdctabb>' || LTrim(RTRIM(gene0002.fn_mask(rw_crapcco.nrdctabb, 'zzzz.zzz.9')))||'</nrdctabb>'||
                                                 '  <cdbccxlt>' || rw_crapcco.cdbccxlt||'</cdbccxlt>'||
                                                 '  <cdhistor>' || rw_crapcco.cdhistor||'</cdhistor>'||
                                                 '  <cdtarhis>' || rw_crapcco.cdtarhis||'</cdtarhis>'|| 
                                                 '  <vlrtarcx>' || to_char(rw_crapcco.vlrtarcx,'fm999g990d00')||'</vlrtarcx>'||
                                                 '  <vlrtarnt>' || to_char(rw_crapcco.vlrtarnt,'fm999g990d00')||'</vlrtarnt>'||
                                                 '  <vltrftaa>' || to_char(rw_crapcco.vltrftaa,'fm999g990d00')||'</vltrftaa>'||
                                                 '  <vlrtrblq>' || to_char(rw_crapcco.vlrtrblq,'fm999g990d00')||'</vlrtrblq>'||
                                                 '  <cdhisblq>' || rw_crapcco.cdhisblq||'</cdhisblq>'||
                                                 '  <dsorgarq>' || rw_crapcco.dsorgarq||'</dsorgarq>'||
                                                 '  <nmdireto>' || rw_crapcco.nmdireto||'</nmdireto>'||
                                                 '  <flgutceb>' || rw_crapcco.flgutceb||'</flgutceb>'||
                                                 '  <dtmvtolt>' || to_char(rw_crapcco.dtmvtolt,'dd/mm/rrrr')||'</dtmvtolt>'||
                                                 '  <flcopcob>' || rw_crapcco.flcopcob||'</flcopcob>'||
                                                 '  <cdcartei>' || rw_crapcco.cdcartei||'</cdcartei>'||
                                                 '  <nmextbcc>' || rw_crapcco.nmdbanco||'</nmextbcc>'||                                                 
                                                 '  <cdagenci>' || rw_crapcco.cdagenci||'</cdagenci>'||
                                                 '  <nrdolote>' || gene0002.fn_mask(to_char(rw_crapcco.nrdolote),'zzz.zz9')||'</nrdolote>'||
                                                 '  <vlrtarif>' || to_char(rw_crapcco.vlrtarif,'fm999g990d00')||'</vlrtarif>'||
                                                 '  <cdhiscxa>' || rw_crapcco.cdhiscxa||'</cdhiscxa>'||
                                                 '  <cdhisnet>' || rw_crapcco.cdhisnet||'</cdhisnet>'||
                                                 '  <cdhistaa>' || rw_crapcco.cdhistaa||'</cdhistaa>'||
                                                 '  <nrlotblq>' || rw_crapcco.nrlotblq||'</nrlotblq>'||
                                                 '  <nrvarcar>' || rw_crapcco.nrvarcar||'</nrvarcar>'||
                                                 '  <nrbloque>' || rw_crapcco.nrbloque||'</nrbloque>'||
                                                 '  <tamannro>' || rw_crapcco.tamannro||'</tamannro>'||
                                                 '  <nmarquiv>' || rw_crapcco.nmarquiv||'</nmarquiv>'||
                                                 '  <flgativo>' || rw_crapcco.flgativo||'</flgativo>'||
                                                 '  <cdoperad>' || rw_crapcco.cdoperad||'-'||vr_nmoperad||'</cdoperad>'||
                                                 '  <flgregis>' || rw_crapcco.flgregis||'</flgregis>'||
                                                 '  <qtdfloat>' || rw_crapcco.qtdfloat||'</qtdfloat>'||                                                                                           
                                                 '  <flserasa>' || rw_crapcco.flserasa||'</flserasa>'||
                                                 '</parametro>');  
      
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</parametros></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);   
                                                   
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_consulta;  
  
  PROCEDURE pc_alteracao(pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                        ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco
                        ,pr_nrdctabb IN crapcco.nrdctabb%TYPE --Conta base
                        ,pr_cdbccxlt IN crapcco.cdbccxlt%TYPE --Caixa/lote
                        ,pr_cdagenci IN crapcco.cdagenci%TYPE --Agencia
                        ,pr_nrdolote IN crapcco.nrdolote%TYPE --Lote
                        ,pr_cdhistor IN crapcco.cdhistor%TYPE --Histórico
                        ,pr_vlrtarif IN crapcco.vlrtarif%TYPE --Valor tarifa
                        ,pr_cdtarhis IN crapcco.cdtarhis%TYPE --Código tarifa
                        ,pr_cdhiscxa IN crapcco.cdhiscxa%TYPE --Histórico caixa
                        ,pr_vlrtarcx IN crapcco.vlrtarcx%TYPE --Valor tarifa caixa
                        ,pr_cdhisnet IN crapcco.cdhisnet%TYPE --Histórico internet
                        ,pr_vlrtarnt IN crapcco.vlrtarnt%TYPE --Valor tarifa internet
                        ,pr_cdhistaa IN crapcco.cdhistaa%TYPE --Histórico TAA
                        ,pr_vltrftaa IN crapcco.vltrftaa%TYPE --Vaor tarifa TAA
                        ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                        ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                        ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                        ,pr_vlrtrblq IN crapcco.vlrtrblq%TYPE --Valor tarifa bloqueto
                        ,pr_cdhisblq IN crapcco.cdhisblq%TYPE --Histórico bloqueto
                        ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                        ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                        ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                        ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                        ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                        ,pr_flgutceb IN crapcco.flgutceb%TYPE --Utiliza CEB
                        ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                        ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
                        ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                        ,pr_dtmvtolt IN VARCHAR2              --Data de movimento
                        ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
                        ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Qtd dias float                      
                        ,pr_dsdepart IN VARCHAR2              --Departamento
                        ,pr_cddopcao IN VARCHAR2              --Opção da tela
                        ,pr_nmdatela IN VARCHAR2              --Nome da tela                        
                        ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_alteracao                           antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Altera cadastro de parametro de cobranca.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/ 
  
    --Busca os parametros de cobranca
    CURSOR cr_crapcco(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrconven IN crapcco.nrconven%TYPE) IS
    SELECT cco.cddbanco
          ,cco.nmdbanco
          ,cco.nrdctabb
          ,cco.cdbccxlt
          ,cco.cdagenci
          ,cco.nrdolote
          ,cco.cdhistor
          ,cco.vlrtarif
          ,cco.cdtarhis
          ,cco.cdhiscxa
          ,cco.vlrtarcx
          ,cco.cdhisnet
          ,cco.vlrtarnt
          ,cco.cdhistaa
          ,cco.vltrftaa
          ,cco.nrlotblq
          ,cco.vlrtrblq
          ,cco.nrvarcar
          ,cco.cdcartei
          ,cco.cdhisblq
          ,cco.nrbloque
          ,cco.tamannro
          ,cco.nmdireto
          ,cco.nmarquiv
          ,cco.flgutceb
          ,cco.flcopcob
          ,cco.flserasa
          ,cco.flgativo
          ,cco.dtmvtolt
          ,cco.cdoperad
          ,cco.flgregis
          ,cco.qtdfloat
          ,cco.dsorgarq
          ,cco.flginter
          ,cco.rowid
      FROM crapcco cco
     WHERE cco.cdcooper = pr_cdcooper
       AND cco.nrconven = pr_nrconven 
           FOR UPDATE NOWAIT;
    rw_crapcco cr_crapcco%ROWTYPE; 
    rw_crapcco_new crapcco%ROWTYPE; 
        
    --Cursor para pegar as ocorrencias bancarias
    CURSOR cr_crapoco(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cddbanco IN crapoco.cddbanco%TYPE)IS
    SELECT crapoco.cdcooper          
          ,crapoco.cddbanco
          ,crapoco.cdocorre
          ,crapoco.tpocorre
     FROM crapoco
    WHERE crapoco.cdcooper = pr_cdcooper
      AND crapoco.cddbanco = pr_cddbanco;
    rw_crapoco cr_crapoco%ROWTYPE;
    
    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nmdcampo VARCHAR2(100);
    vr_des_erro VARCHAR2(10);
    vr_nmresbcc crapban.nmresbcc%TYPE;
    
    --Controle de erros
    vr_cdcritic NUMBER := 0;
    vr_dscritic VARCHAR2(4000);  
    vr_exc_erro EXCEPTION;
  
    -- Variável exceção para locke
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);
  
  BEGIN
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCCO'
                              ,pr_action => null); 
                                 
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
    
      RAISE vr_exc_erro;
    END IF;   
    
    TELA_CADCCO.pc_valida_informacoes(pr_cdcooper => vr_cdcooper --Código da cooperativa
                                     ,pr_nrconven => pr_nrconven --Convenio
                                     ,pr_cddbanco => pr_cddbanco --Banco
                                     ,pr_nrdctabb => pr_nrdctabb --Conta base
                                     ,pr_cdbccxlt => pr_cdbccxlt --Caixa/lote
                                     ,pr_cdagenci => pr_cdagenci --Agencia
                                     ,pr_nrdolote => pr_nrdolote --Lote
                                     ,pr_cdhistor => pr_cdhistor --Histórico
                                     ,pr_vlrtarif => pr_vlrtarif --Valor tarifa
                                     ,pr_cdtarhis => pr_cdtarhis --Código tarifa
                                     ,pr_cdhiscxa => pr_cdhiscxa --Histórico caixa
                                     ,pr_vlrtarcx => pr_vlrtarcx --Valor tarifa caixa
                                     ,pr_cdhisnet => pr_cdhisnet --Histórico internet
                                     ,pr_vlrtarnt => pr_vlrtarnt --Valor tarifa internet
                                     ,pr_cdhistaa => pr_cdhistaa --Histórico TAA
                                     ,pr_vltrftaa => pr_vltrftaa --Vaor tarifa TAA
                                     ,pr_nrlotblq => pr_nrlotblq --Lote bloqueto
                                     ,pr_nrvarcar => pr_nrvarcar --Variacação da carteira de cobrança
                                     ,pr_cdcartei => pr_cdcartei --Código da carteira
                                     ,pr_vlrtrblq => pr_vlrtrblq --Valor tarifa bloqueto
                                     ,pr_cdhisblq => pr_cdhisblq --Histórico bloqueto
                                     ,pr_nrbloque => pr_nrbloque --Número bloqueto
                                     ,pr_dsorgarq => pr_dsorgarq --Origem do arquivo
                                     ,pr_tamannro => pr_tamannro --Tamanho nosso número
                                     ,pr_nmdireto => pr_nmdireto --Nome do diretório
                                     ,pr_nmarquiv => pr_nmarquiv --Nome do arquivo
                                     ,pr_flgutceb => pr_flgutceb --Utiliza CEB
                                     ,pr_flcopcob => pr_flcopcob --Informe se utiliza sistema CoopCob
                                     ,pr_flserasa => pr_flserasa --Pode negativar no Serasa. (0=Nao, 1=Sim)
                                     ,pr_flgativo => pr_flgativo --Ativo/inativo
                                     ,pr_dtmvtolt => pr_dtmvtolt --Data de movimento
                                     ,pr_flgregis => pr_flgregis --Cobrança registrada
                                     ,pr_qtdfloat => pr_qtdfloat --Qtd dias float                      
                                     ,pr_dsdepart => pr_dsdepart --Departamento
                                     ,pr_cddopcao => pr_cddopcao --Opção da tela
                                     ,pr_nmdatela => pr_nmdatela --Nome da tela                        
                                     ,pr_nmdbanco => vr_nmresbcc --Nome do banco                                     
                                     ,pr_cdcritic => vr_cdcritic --Cõdigo da critica
                                     ,pr_dscritic => vr_dscritic --Descrção da critica
                                     ,pr_nmdcampo => vr_nmdcampo --Nome do campo de retorno
                                     ,pr_des_erro => vr_des_erro); --Retorno OK;NOK
                                     
    IF vr_des_erro <> 'OK'      OR 
       nvl(vr_cdcritic,0) <> 0  OR 
       vr_dscritic IS NOT NULL  THEN      
       
      RAISE vr_exc_erro;
    
    END IF;
    
    BEGIN
      -- Busca associado
      OPEN cr_crapcco(pr_cdcooper => vr_cdcooper,
                      pr_nrconven => pr_nrconven);
                      
      FETCH cr_crapcco INTO rw_crapcco;
           
      -- Gerar erro caso não encontre
      IF cr_crapcco%NOTFOUND THEN
        
        -- Fechar cursor pois teremos raise
        CLOSE cr_crapcco;
         
         --MOnta mensagem de erro
        vr_cdcritic := 563;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         
         -- Gera exceção
         RAISE vr_exc_erro;
         
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcco;
      END IF; 
        
    EXCEPTION
      WHEN vr_exc_locked THEN
        gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPCCO'
                            ,pr_nrdrecid    => ''
                            ,pr_des_reto    => pr_des_erro
                            ,pt_tab_locktab => vr_tab_locktab);
                            
        IF pr_des_erro = 'OK' THEN
          FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
            vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPCCO)' || 
                           ' - ' || vr_tab_locktab(VR_IND).nmusuari;
          END LOOP;
        END IF;
        
        RAISE vr_exc_erro;
         
    END;        
    
    --Realiza a alteração do registro de convenio                          
    BEGIN
      
      UPDATE crapcco SET crapcco.cddbanco = pr_cddbanco
                        ,crapcco.nmdbanco = vr_nmresbcc
                        ,crapcco.nrdctabb = pr_nrdctabb
                        ,crapcco.cdbccxlt = pr_cdbccxlt
                        ,crapcco.cdagenci = pr_cdagenci
                        ,crapcco.nrdolote = pr_nrdolote
                        ,crapcco.cdhistor = pr_cdhistor
                        ,crapcco.vlrtarif = pr_vlrtarif
                        ,crapcco.cdtarhis = pr_cdtarhis
                        ,crapcco.cdhiscxa = pr_cdhiscxa
                        ,crapcco.vlrtarcx = pr_vlrtarcx
                        ,crapcco.cdhisnet = pr_cdhisnet
                        ,crapcco.vlrtarnt = pr_vlrtarnt
                        ,crapcco.cdhistaa = pr_cdhistaa
                        ,crapcco.vltrftaa = pr_vltrftaa
                        ,crapcco.nrlotblq = pr_nrlotblq
                        ,crapcco.vlrtrblq = pr_vlrtrblq
                        ,crapcco.nrvarcar = pr_nrvarcar
                        ,crapcco.cdcartei = pr_cdcartei
                        ,crapcco.cdhisblq = pr_cdhisblq
                        ,crapcco.nrbloque = pr_nrbloque
                        ,crapcco.dsorgarq = pr_dsorgarq
                        ,crapcco.tamannro = pr_tamannro
                        ,crapcco.nmdireto = nvl(trim(pr_nmdireto),' ')
                        ,crapcco.nmarquiv = nvl(trim(pr_nmarquiv),' ')
                        ,crapcco.flgutceb = pr_flgutceb
                        ,crapcco.flcopcob = pr_flcopcob
                        ,crapcco.flserasa = pr_flserasa
                        ,crapcco.flgativo = pr_flgativo
                        ,crapcco.dtmvtolt = to_date(pr_dtmvtolt,'DD/MM/RRRR')
                        ,crapcco.cdoperad = vr_cdoperad
                        ,crapcco.flgregis = pr_flgregis
                        ,crapcco.qtdfloat = pr_qtdfloat
                        ,crapcco.flginter = decode(pr_dsorgarq,'INTERNET',1,'PROTESTO',1,'IMPRESSO PELO SOFTWARE',1,0)                                        
                  WHERE crapcco.rowid = rw_crapcco.rowid
              RETURNING crapcco.cdcooper
                       ,crapcco.nrconven
                       ,crapcco.cddbanco
                       ,crapcco.nmdbanco
                       ,crapcco.nrdctabb
                       ,crapcco.cdbccxlt
                       ,crapcco.cdagenci
                       ,crapcco.nrdolote
                       ,crapcco.cdhistor
                       ,crapcco.vlrtarif
                       ,crapcco.cdtarhis
                       ,crapcco.cdhiscxa
                       ,crapcco.vlrtarcx
                       ,crapcco.cdhisnet
                       ,crapcco.vlrtarnt
                       ,crapcco.cdhistaa
                       ,crapcco.vltrftaa
                       ,crapcco.nrlotblq
                       ,crapcco.vlrtrblq
                       ,nvl(crapcco.nrvarcar,0)
                       ,nvl(crapcco.cdcartei,0)
                       ,crapcco.cdhisblq
                       ,crapcco.nrbloque
                       ,crapcco.dsorgarq
                       ,crapcco.tamannro
                       ,nvl(trim(crapcco.nmdireto),' ')
                       ,nvl(trim(crapcco.nmarquiv),' ')
                       ,crapcco.flgutceb
                       ,crapcco.flcopcob
                       ,crapcco.flserasa
                       ,crapcco.flgativo
                       ,crapcco.dtmvtolt
                       ,crapcco.cdoperad
                       ,crapcco.flgregis
                       ,crapcco.qtdfloat
                       ,crapcco.flginter
                  INTO rw_crapcco_new.cdcooper
                      ,rw_crapcco_new.nrconven
                      ,rw_crapcco_new.cddbanco
                      ,rw_crapcco_new.nmdbanco
                      ,rw_crapcco_new.nrdctabb
                      ,rw_crapcco_new.cdbccxlt
                      ,rw_crapcco_new.cdagenci
                      ,rw_crapcco_new.nrdolote
                      ,rw_crapcco_new.cdhistor
                      ,rw_crapcco_new.vlrtarif
                      ,rw_crapcco_new.cdtarhis
                      ,rw_crapcco_new.cdhiscxa
                      ,rw_crapcco_new.vlrtarcx
                      ,rw_crapcco_new.cdhisnet
                      ,rw_crapcco_new.vlrtarnt
                      ,rw_crapcco_new.cdhistaa
                      ,rw_crapcco_new.vltrftaa
                      ,rw_crapcco_new.nrlotblq
                      ,rw_crapcco_new.vlrtrblq
                      ,rw_crapcco_new.nrvarcar
                      ,rw_crapcco_new.cdcartei
                      ,rw_crapcco_new.cdhisblq
                      ,rw_crapcco_new.nrbloque
                      ,rw_crapcco_new.dsorgarq
                      ,rw_crapcco_new.tamannro
                      ,rw_crapcco_new.nmdireto
                      ,rw_crapcco_new.nmarquiv
                      ,rw_crapcco_new.flgutceb
                      ,rw_crapcco_new.flcopcob
                      ,rw_crapcco_new.flserasa
                      ,rw_crapcco_new.flgativo
                      ,rw_crapcco_new.dtmvtolt
                      ,rw_crapcco_new.cdoperad
                      ,rw_crapcco_new.flgregis
                      ,rw_crapcco_new.qtdfloat
                      ,rw_crapcco_new.flginter;
                      
    EXCEPTION
      WHEN OTHERS THEN      
        --Monta mensagem de erro
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel atualizar o convenio - ' || sqlerrm;
        
        RAISE vr_exc_erro;             
    
    END;
          
    IF pr_flgregis = 1 THEN
         
      IF pr_flgregis <> rw_crapcco.flgregis THEN
        
        BEGIN 
          FOR rw_crapoco IN cr_crapoco(pr_cdcooper => vr_cdcooper
                                      ,pr_cddbanco => pr_cddbanco) LOOP
                                      
            INSERT INTO crapcct(crapcct.cdcooper 
                               ,crapcct.nrconven
                               ,crapcct.cddbanco
                               ,crapcct.cdocorre
                               ,crapcct.tpocorre
                               ,crapcct.vltarifa
                               ,crapcct.cdtarhis
                               ,crapcct.cdoperad
                               ,crapcct.dtaltera
                               ,crapcct.hrtransa)
                         VALUES(rw_crapcco_new.cdcooper
                               ,rw_crapcco_new.nrconven
                               ,rw_crapcco_new.cddbanco
                               ,rw_crapoco.cdocorre
                               ,rw_crapoco.tpocorre
                               ,0
                               ,0
                               ,vr_cdoperad
                               ,to_date(pr_dtmvtolt,'DD/MM/RRRR')
                               ,GENE0002.fn_busca_time);                          
                                      
          END LOOP; 
          
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel incluir o(s) registro(s) de tarifas do convenio.';          
            
            RAISE vr_exc_erro;
        END;
        
      END IF;
      
    ELSE    
                                            
      IF pr_flgregis <> rw_crapcco.flgregis THEN
            
        BEGIN 
          DELETE crapcct
           WHERE crapcct.cdcooper = vr_cdcooper
             AND crapcct.nrconven = pr_nrconven;
        
        EXCEPTION
          WHEN OTHERS THEN
            --Monta mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel excluir as tarifas.';
            
            RAISE vr_exc_erro;
               
        END;
         
      END IF;                         
          
    END IF;
                         
    IF rw_crapcco.cddbanco <> rw_crapcco_new.cddbanco THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Banco'
                   ,pr_vlrcampo => rw_crapcco.cddbanco
                   ,pr_vlcampo2 => rw_crapcco_new.cddbanco
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.nmdbanco <> rw_crapcco_new.nmdbanco THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Nome do banco'
                   ,pr_vlrcampo => rw_crapcco.nmdbanco
                   ,pr_vlcampo2 => rw_crapcco_new.nmdbanco
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.nrdctabb <> rw_crapcco_new.nrdctabb   THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Conta base'
                   ,pr_vlrcampo => rw_crapcco.nrdctabb
                   ,pr_vlcampo2 => rw_crapcco_new.nrdctabb
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.flgregis <> rw_crapcco_new.flgregis   THEN
        pc_gera_log(pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Cobranca Registrada'
                   ,pr_vlrcampo => rw_crapcco.flgregis
                   ,pr_vlcampo2 => rw_crapcco_new.flgregis
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.cdbccxlt <> rw_crapcco_new.cdbccxlt THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Banco/Caixa'
                   ,pr_vlrcampo => rw_crapcco.cdbccxlt
                   ,pr_vlcampo2 => rw_crapcco_new.cdbccxlt
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.cdagenci <> rw_crapcco_new.cdagenci THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'PA'
                   ,pr_vlrcampo => rw_crapcco.cdagenci
                   ,pr_vlcampo2 => rw_crapcco_new.cdagenci
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.nrdolote <> rw_crapcco_new.nrdolote THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Lote'
                   ,pr_vlrcampo => rw_crapcco.nrdolote
                   ,pr_vlcampo2 => rw_crapcco_new.nrdolote
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.cdhistor <> rw_crapcco_new.cdhistor THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Hist. tarifa especial'
                   ,pr_vlrcampo => rw_crapcco.cdhistor
                   ,pr_vlcampo2 => rw_crapcco_new.cdhistor
                   ,pr_des_erro => pr_des_erro);
    END IF;
                              
    IF rw_crapcco.vlrtarif <> rw_crapcco_new.vlrtarif THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Valor da tarifa'
                   ,pr_vlrcampo => TRIM(TO_CHAR(rw_crapcco.vlrtarif, 'fm999g990d00'))
                   ,pr_vlcampo2 => TRIM(TO_CHAR(rw_crapcco_new.vlrtarif, 'fm999g990d00'))
                   ,pr_des_erro => pr_des_erro);
    END IF;
      
    IF rw_crapcco.cdtarhis <> rw_crapcco_new.cdtarhis THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Hist. tarifa'
                   ,pr_vlrcampo => rw_crapcco.cdtarhis
                   ,pr_vlcampo2 => rw_crapcco_new.cdtarhis
                   ,pr_des_erro => pr_des_erro);
    END IF;
          
    IF rw_crapcco.cdhiscxa <> rw_crapcco_new.cdhiscxa THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Hist. tarifa boleto pago na Coop.'
                   ,pr_vlrcampo => rw_crapcco.cdhiscxa
                   ,pr_vlcampo2 => rw_crapcco_new.cdhiscxa
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.vlrtarcx <> rw_crapcco_new.vlrtarcx THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Valor tarifa boleto pago na Coop.'
                   ,pr_vlrcampo => TRIM(TO_CHAR(rw_crapcco.vlrtarcx, 'fm999g990d00'))
                   ,pr_vlcampo2 => TRIM(TO_CHAR(rw_crapcco_new.vlrtarcx, 'fm999g990d00'))
                   ,pr_des_erro => pr_des_erro);
    END IF;
          
    IF rw_crapcco.cdhisnet <> rw_crapcco_new.cdhisnet THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Hist. tarifa boleto pago na Internet'
                   ,pr_vlrcampo => rw_crapcco.cdhisnet
                   ,pr_vlcampo2 => rw_crapcco_new.cdhisnet
                   ,pr_des_erro => pr_des_erro);
    END IF;
       
    IF rw_crapcco.vlrtarnt <> rw_crapcco_new.vlrtarnt THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Valor tarifa boleto pago na internet'
                   ,pr_vlrcampo => TRIM(TO_CHAR(rw_crapcco.vlrtarnt, 'fm999g990d00'))
                   ,pr_vlcampo2 => TRIM(TO_CHAR(rw_crapcco_new.vlrtarnt, 'fm999g990d00'))
                   ,pr_des_erro => pr_des_erro);
    END IF;
     
    IF rw_crapcco.cdhistaa <> rw_crapcco_new.cdhistaa THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Hist. tarifa TAA'
                   ,pr_vlrcampo => rw_crapcco.cdhistaa
                   ,pr_vlcampo2 => rw_crapcco_new.cdhistaa
                   ,pr_des_erro => pr_des_erro);
    END IF;
       
    IF rw_crapcco.vltrftaa <> rw_crapcco_new.vltrftaa THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Valor tarifa TAA'
                   ,pr_vlrcampo => TRIM(TO_CHAR(rw_crapcco.vltrftaa, 'fm999g990d00'))
                   ,pr_vlcampo2 => TRIM(TO_CHAR(rw_crapcco_new.vltrftaa, 'fm999g990d00'))
                   ,pr_des_erro => pr_des_erro);
    END IF;
          
    IF rw_crapcco.nrlotblq <> rw_crapcco_new.nrlotblq THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Lote impresso bloq.'
                   ,pr_vlrcampo => rw_crapcco.nrlotblq
                   ,pr_vlcampo2 => rw_crapcco_new.nrlotblq
                   ,pr_des_erro => pr_des_erro);
    END IF;
       
    IF rw_crapcco.vlrtrblq <> rw_crapcco_new.vlrtrblq THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Tarifa impresso bloq.'
                   ,pr_vlrcampo => TRIM(TO_CHAR(rw_crapcco.vlrtrblq, 'fm999g990d00'))
                   ,pr_vlcampo2 => TRIM(TO_CHAR(rw_crapcco_new.vlrtrblq, 'fm999g990d00'))
                   ,pr_des_erro => pr_des_erro);
    END IF;
       
    IF rw_crapcco.nrvarcar <> rw_crapcco_new.nrvarcar THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Var. carteira'
                   ,pr_vlrcampo => rw_crapcco.nrvarcar
                   ,pr_vlcampo2 => rw_crapcco_new.nrvarcar
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.cdcartei <> rw_crapcco_new.cdcartei THEN
        pc_gera_log (pr_cdcooper => vr_cdcooper
                    ,pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 2                   
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Cod. carteira'
                    ,pr_vlrcampo => rw_crapcco.cdcartei
                    ,pr_vlcampo2 => rw_crapcco_new.cdcartei
                    ,pr_des_erro => pr_des_erro);
    END IF;
       
    IF rw_crapcco.cdhisblq <> rw_crapcco_new.cdhisblq THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Hist. impresso bloqueto'
                   ,pr_vlrcampo => rw_crapcco.cdhisblq
                   ,pr_vlcampo2 => rw_crapcco_new.cdhisblq
                   ,pr_des_erro => pr_des_erro);
    END IF;
          
    IF rw_crapcco.nrbloque <> rw_crapcco_new.nrbloque THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Nro bloqueto'
                   ,pr_vlrcampo => rw_crapcco.nrbloque
                   ,pr_vlcampo2 => rw_crapcco_new.nrbloque
                   ,pr_des_erro => pr_des_erro);
    END IF;
       
    IF rw_crapcco.tamannro <> rw_crapcco_new.tamannro THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Tamanho do nro'
                   ,pr_vlrcampo => rw_crapcco.tamannro
                   ,pr_vlcampo2 => rw_crapcco_new.tamannro
                   ,pr_des_erro => pr_des_erro);
    END IF;
       
    IF nvl(trim(rw_crapcco.nmdireto),' ') <> rw_crapcco_new.nmdireto THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Diretorio'
                   ,pr_vlrcampo => nvl(trim(rw_crapcco.nmdireto),' ')
                   ,pr_vlcampo2 => rw_crapcco_new.nmdireto
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF nvl(trim(rw_crapcco.nmarquiv),' ') <> rw_crapcco_new.nmarquiv THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Arquivo'
                   ,pr_vlrcampo => rw_crapcco.nmarquiv
                   ,pr_vlcampo2 => rw_crapcco_new.nmarquiv
                   ,pr_des_erro => pr_des_erro);
    END IF;                                                  
                                                  
    IF rw_crapcco.flgutceb <> rw_crapcco_new.flgutceb THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Utiliza sequncia CADCEB'
                   ,pr_vlrcampo => (CASE rw_crapcco.flgutceb WHEN 1 THEN 'SIM' ELSE 'NAO' END)
                   ,pr_vlcampo2 => (CASE rw_crapcco_new.flgutceb WHEN 1 THEN 'SIM' ELSE 'NAO' END)
                   ,pr_des_erro => pr_des_erro);
    END IF;
                                                    
    IF rw_crapcco.flcopcob <> rw_crapcco_new.flcopcob THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Utiliza CoopCob'
                   ,pr_vlrcampo => (CASE rw_crapcco.flcopcob WHEN 1 THEN 'SIM' ELSE 'NAO' END)
                   ,pr_vlcampo2 => (CASE rw_crapcco_new.flcopcob WHEN 1 THEN 'SIM' ELSE 'NAO' END)
                   ,pr_des_erro => pr_des_erro);
    END IF;
         
    IF rw_crapcco.flgativo <> rw_crapcco_new.flgativo THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Ativo'
                   ,pr_vlrcampo => (CASE rw_crapcco.flgativo WHEN 1 THEN 'ATIVO' ELSE 'INATIVO' END)
                   ,pr_vlcampo2 => (CASE rw_crapcco_new.flgativo WHEN 1 THEN 'ATIVO' ELSE 'INATIVO' END) 
                   ,pr_des_erro => pr_des_erro);
       
    END IF;
    
    IF rw_crapcco.dtmvtolt <> rw_crapcco_new.dtmvtolt THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Data ult. alteracao'
                   ,pr_vlrcampo => rw_crapcco.dtmvtolt
                   ,pr_vlcampo2 => rw_crapcco_new.dtmvtolt
                   ,pr_des_erro => pr_des_erro);
    END IF;
         
    IF rw_crapcco.cdoperad <> rw_crapcco_new.cdoperad THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Operador'
                   ,pr_vlrcampo => rw_crapcco.cdoperad
                   ,pr_vlcampo2 => rw_crapcco_new.cdoperad
                   ,pr_des_erro => pr_des_erro);
    
    END IF;
      
    IF rw_crapcco.dsorgarq  <> rw_crapcco_new.dsorgarq THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Origem arquivo'
                   ,pr_vlrcampo => rw_crapcco.dsorgarq
                   ,pr_vlcampo2 => rw_crapcco_new.dsorgarq
                   ,pr_des_erro => pr_des_erro);
    END IF;
     
    IF rw_crapcco.qtdfloat <> rw_crapcco_new.qtdfloat THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Float'
                   ,pr_vlrcampo => rw_crapcco.qtdfloat
                   ,pr_vlcampo2 => rw_crapcco_new.qtdfloat
                   ,pr_des_erro => pr_des_erro);
    END IF;
    
    IF rw_crapcco.flginter <> rw_crapcco_new.flginter   THEN
       pc_gera_log (pr_cdcooper => vr_cdcooper
                   ,pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Convenio internet'
                   ,pr_vlrcampo => rw_crapcco.flginter
                   ,pr_vlcampo2 => rw_crapcco_new.flginter
                   ,pr_des_erro => pr_des_erro);
    END IF;    
    
    pr_des_erro := 'OK';
    
    COMMIT;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN 
                   
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := vr_nmdcampo;
              
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                     
      ROLLBACK;
                                                                                                   
    WHEN OTHERS THEN 
      
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_alteracao --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
      ROLLBACK;
      
  END pc_alteracao;   
  
  PROCEDURE pc_exclusao (pr_nrconven  IN crapcco.nrconven%TYPE --Convenio
                        ,pr_dtmvtolt  IN VARCHAR2              --Data de movimento 
                        ,pr_cddopcao  IN VARCHAR               --Opção da tela
                        ,pr_dsdepart  IN VARCHAR               --Departamento
                        ,pr_nmdatela IN VARCHAR2               --Nome da tela                        
                        ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK) 
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_exclusao                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Exclui cadastro de parametro de cobranca.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/ 
    
    --Busca os parametros de cobranca
    CURSOR cr_crapcco(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrconven IN crapcco.nrconven%TYPE) IS
    SELECT crapcco.nrconven
          ,crapcco.flgregis
      FROM crapcco
     WHERE crapcco.nrconven = pr_nrconven 
       AND crapcco.cdcooper = pr_cdcooper
           FOR UPDATE NOWAIT;
    rw_crapcco cr_crapcco%ROWTYPE;   
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;
      
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    -- Variável exceção para locke
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
  BEGIN
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCCO'
                              ,pr_action => null); 
                                
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF pr_dsdepart <> 'TI' AND
       pr_dsdepart <> 'SUPORTE' THEN 
       
      vr_cdcritic := 36;      
      RAISE vr_exc_erro;
      
    END IF;
    
    BEGIN
    
      --Busca o convenio
      OPEN cr_crapcco(pr_cdcooper => vr_cdcooper
                     ,pr_nrconven => pr_nrconven);
    
      FETCH cr_crapcco INTO rw_crapcco;
      
      IF cr_crapcco%NOTFOUND THEN
        
        --Fecha o cursor
        CLOSE cr_crapcco;
        
        --MOnta mensagem de erro
        vr_cdcritic := 563;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        RAISE vr_exc_erro;
        
      END IF;
      
      --Fecha o cursor
      CLOSE cr_crapcco;
        
    EXCEPTION
      WHEN vr_exc_locked THEN
        gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPCCO'
                            ,pr_nrdrecid    => ''
                            ,pr_des_reto    => pr_des_erro
                            ,pt_tab_locktab => vr_tab_locktab);
                            
        IF pr_des_erro <> 'OK' THEN
          FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
            vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPCCO)' || 
                           ' - ' || vr_tab_locktab(VR_IND).nmusuari;
          END LOOP;
        END IF;
        
        RAISE vr_exc_erro;
         
    END;
    
    --Se for convenio de cobrança registrada elimina as tarifas
    IF rw_crapcco.flgregis = 1 THEN
      
      BEGIN
        
        DELETE crapcct
         WHERE crapcct.cdcooper = vr_cdcooper
           AND crapcct.nrconven = pr_nrconven;
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel excluir o(s) registro(s) de tarifas do convenio.';
          
          RAISE vr_exc_erro;
      END;
    
    END IF;
    
    --Elimina o registro do convenio
    BEGIN
    
      DELETE crapcco
       WHERE crapcco.cdcooper = vr_cdcooper
         AND crapcco.nrconven = pr_nrconven;
         
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel excluir o registro de parametros do convenio.';
        
        RAISE vr_exc_erro;
    
    END;
    
    pc_gera_log (pr_cdcooper => vr_cdcooper
                ,pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 3
                ,pr_nrconven => pr_nrconven
                ,pr_dsdcampo => ''
                ,pr_vlrcampo => ''
                ,pr_vlcampo2 => ''
                ,pr_des_erro => pr_des_erro); 
                                                 
    pr_des_erro := 'OK';
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN 
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');  
                                     
      ROLLBACK;
                                                                                                     
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_exclusao --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
      ROLLBACK;
      
  END pc_exclusao;                      
 
  PROCEDURE pc_inclusao (pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                        ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco
                        ,pr_nrdctabb IN crapcco.nrdctabb%TYPE --Conta base
                        ,pr_cdbccxlt IN crapcco.cdbccxlt%TYPE --Caixa/lote
                        ,pr_cdagenci IN crapcco.cdagenci%TYPE --Agencia
                        ,pr_nrdolote IN crapcco.nrdolote%TYPE --Lote
                        ,pr_cdhistor IN crapcco.cdhistor%TYPE --Histórico
                        ,pr_vlrtarif IN crapcco.vlrtarif%TYPE --Valor tarifa
                        ,pr_cdtarhis IN crapcco.cdtarhis%TYPE --Código tarifa
                        ,pr_cdhiscxa IN crapcco.cdhiscxa%TYPE --Histórico caixa
                        ,pr_vlrtarcx IN crapcco.vlrtarcx%TYPE --Valor tarifa caixa
                        ,pr_cdhisnet IN crapcco.cdhisnet%TYPE --Histórico internet
                        ,pr_vlrtarnt IN crapcco.vlrtarnt%TYPE --Valor tarifa internet
                        ,pr_cdhistaa IN crapcco.cdhistaa%TYPE --Histórico TAA
                        ,pr_vltrftaa IN crapcco.vltrftaa%TYPE --Vaor tarifa TAA
                        ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                        ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                        ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                        ,pr_vlrtrblq IN crapcco.vlrtrblq%TYPE --Valor tarifa bloqueto
                        ,pr_cdhisblq IN crapcco.cdhisblq%TYPE --Histórico bloqueto
                        ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                        ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                        ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                        ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                        ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                        ,pr_flgutceb IN crapcco.flgutceb%TYPE --Utiliza CEB
                        ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                        ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
                        ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                        ,pr_dtmvtolt VARCHAR2                 --Data de movimento                       
                        ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
                        ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Qtd dias float                      
                        ,pr_dsdepart IN VARCHAR2              --Departamento
                        ,pr_cddopcao IN VARCHAR2              --Opção da tela
                        ,pr_nmdatela IN VARCHAR2              --Nome da tela                        
                        ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_inclusao                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Inclui cadastro de parametro de cobranca.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/ 
        
    --Cursor para encontrar a cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
                  
    --Cursor para pegar as ocorrencias bancarias
    CURSOR cr_crapoco(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cddbanco IN crapoco.cddbanco%TYPE)IS
    SELECT crapoco.cdcooper          
          ,crapoco.cddbanco
          ,crapoco.cdocorre
          ,crapoco.tpocorre
     FROM crapoco
    WHERE crapoco.cdcooper = pr_cdcooper
      AND crapoco.cddbanco = pr_cddbanco;
    rw_crapoco cr_crapoco%ROWTYPE;
          
    --Variaveis locais    
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nmdcampo VARCHAR2(100);
    vr_des_erro VARCHAR2(10);
    vr_nmresbcc crapban.nmresbcc%TYPE;
    
    --Variaveis de critica
    vr_exc_erro EXCEPTION;
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(200);
    
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCCO'
                              ,pr_action => null); 
                               
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
     
      RAISE vr_exc_erro;
      
    END IF;    
        
    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;
    
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      
      -- Montar mensagem de critica
      pr_cdcritic := 651;
      
      -- Busca critica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
            
      RAISE vr_exc_erro;
      
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF; 
    
    TELA_CADCCO.pc_valida_informacoes(pr_cdcooper => vr_cdcooper --Código da cooperativa
                                     ,pr_nrconven => pr_nrconven --Convenio
                                     ,pr_cddbanco => pr_cddbanco --Banco                                     
                                     ,pr_nrdctabb => pr_nrdctabb --Conta base
                                     ,pr_cdbccxlt => pr_cdbccxlt --Caixa/lote
                                     ,pr_cdagenci => pr_cdagenci --Agencia
                                     ,pr_nrdolote => pr_nrdolote --Lote
                                     ,pr_cdhistor => pr_cdhistor --Histórico
                                     ,pr_vlrtarif => pr_vlrtarif --Valor tarifa
                                     ,pr_cdtarhis => pr_cdtarhis --Código tarifa
                                     ,pr_cdhiscxa => pr_cdhiscxa --Histórico caixa
                                     ,pr_vlrtarcx => pr_vlrtarcx --Valor tarifa caixa
                                     ,pr_cdhisnet => pr_cdhisnet --Histórico internet
                                     ,pr_vlrtarnt => pr_vlrtarnt --Valor tarifa internet
                                     ,pr_cdhistaa => pr_cdhistaa --Histórico TAA
                                     ,pr_vltrftaa => pr_vltrftaa --Vaor tarifa TAA
                                     ,pr_nrlotblq => pr_nrlotblq --Lote bloqueto
                                     ,pr_nrvarcar => pr_nrvarcar --Variacação da carteira de cobrança
                                     ,pr_cdcartei => pr_cdcartei --Código da carteira
                                     ,pr_vlrtrblq => pr_vlrtrblq --Valor tarifa bloqueto
                                     ,pr_cdhisblq => pr_cdhisblq --Histórico bloqueto
                                     ,pr_nrbloque => pr_nrbloque --Número bloqueto
                                     ,pr_dsorgarq => pr_dsorgarq --Origem do arquivo
                                     ,pr_tamannro => pr_tamannro --Tamanho nosso número
                                     ,pr_nmdireto => pr_nmdireto --Nome do diretório
                                     ,pr_nmarquiv => pr_nmarquiv --Nome do arquivo
                                     ,pr_flgutceb => pr_flgutceb --Utiliza CEB
                                     ,pr_flcopcob => pr_flcopcob --Informe se utiliza sistema CoopCob
                                     ,pr_flserasa => pr_flserasa --Pode negativar no Serasa. (0=Nao, 1=Sim)
                                     ,pr_flgativo => pr_flgativo --Ativo/inativo
                                     ,pr_dtmvtolt => pr_dtmvtolt --Data de movimento
                                     ,pr_flgregis => pr_flgregis --Cobrança registrada
                                     ,pr_qtdfloat => pr_qtdfloat --Qtd dias float                      
                                     ,pr_dsdepart => pr_dsdepart --Departamento
                                     ,pr_cddopcao => pr_cddopcao --Opção da tela
                                     ,pr_nmdatela => pr_nmdatela --Nome da tela        
                                     ,pr_nmdbanco => vr_nmresbcc --Nome do banco                
                                     ,pr_cdcritic => vr_cdcritic --Cõdigo da critica
                                     ,pr_dscritic => vr_dscritic --Descrção da critica
                                     ,pr_nmdcampo => vr_nmdcampo --Nome do campo de retorno
                                     ,pr_des_erro => vr_des_erro); --Retorno OK;NOK
                                     
    IF vr_des_erro <> 'OK'      OR 
       nvl(vr_cdcritic,0) <> 0  OR 
       vr_dscritic IS NOT NULL  THEN      
       
      RAISE vr_exc_erro;
    
    END IF;
     
    --Incluir o regitros de convenio   
    BEGIN
      
      INSERT INTO crapcco(crapcco.nrconven
                         ,crapcco.cddbanco
                         ,crapcco.nmdbanco
                         ,crapcco.nrdctabb
                         ,crapcco.cdbccxlt
                         ,crapcco.cdagenci
                         ,crapcco.nrdolote
                         ,crapcco.cdhistor
                         ,crapcco.vlrtarif
                         ,crapcco.cdtarhis
                         ,crapcco.cdhiscxa
                         ,crapcco.vlrtarcx
                         ,crapcco.cdhisnet
                         ,crapcco.vlrtarnt
                         ,crapcco.cdhistaa
                         ,crapcco.vltrftaa
                         ,crapcco.nrlotblq
                         ,crapcco.nrvarcar
                         ,crapcco.cdcartei
                         ,crapcco.vlrtrblq
                         ,crapcco.cdhisblq
                         ,crapcco.nrbloque
                         ,crapcco.dsorgarq
                         ,crapcco.tamannro
                         ,crapcco.nmdireto
                         ,crapcco.nmarquiv
                         ,crapcco.flgutceb
                         ,crapcco.flcopcob
                         ,crapcco.flserasa
                         ,crapcco.flgativo
                         ,crapcco.dtmvtolt
                         ,crapcco.cdoperad
                         ,crapcco.cdcooper
                         ,crapcco.flgregis
                         ,crapcco.qtdfloat
                         ,crapcco.flginter)
                  VALUES(pr_nrconven
                        ,pr_cddbanco
                        ,vr_nmresbcc
                        ,pr_nrdctabb
                        ,pr_cdbccxlt
                        ,pr_cdagenci
                        ,pr_nrdolote
                        ,pr_cdhistor
                        ,pr_vlrtarif
                        ,pr_cdtarhis
                        ,pr_cdhiscxa
                        ,pr_vlrtarcx
                        ,pr_cdhisnet
                        ,pr_vlrtarnt
                        ,pr_cdhistaa
                        ,pr_vltrftaa
                        ,pr_nrlotblq
                        ,nvl(pr_nrvarcar,0)
                        ,nvl(pr_cdcartei,0)
                        ,pr_vlrtrblq
                        ,pr_cdhisblq
                        ,pr_nrbloque
                        ,pr_dsorgarq
                        ,pr_tamannro
                        ,pr_nmdireto
                        ,pr_nmarquiv
                        ,pr_flgutceb
                        ,pr_flcopcob
                        ,pr_flserasa
                        ,pr_flgativo
                        ,to_date(pr_dtmvtolt,'DD/MM/RRRR')
                        ,vr_cdoperad
                        ,vr_cdcooper
                        ,pr_flgregis
                        ,pr_qtdfloat
                        ,decode(pr_dsorgarq,'INTERNET',1,'PROTESTO',1,'IMPRESSO PELO SOFTWARE',1,0) );
                          
    EXCEPTION
      WHEN OTHERS THEN  
        
        --Montaq mensagem de erro
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel incluir o convenio.' || SQLERRM;
                
        RAISE vr_exc_erro;
    
    END;
    
    IF pr_flgregis = 1 THEN
      
      BEGIN 
        FOR rw_crapoco IN cr_crapoco(pr_cdcooper => vr_cdcooper
                                    ,pr_cddbanco => pr_cddbanco) LOOP
                                    
          INSERT INTO crapcct(crapcct.cdcooper 
                             ,crapcct.nrconven
                             ,crapcct.cddbanco
                             ,crapcct.cdocorre
                             ,crapcct.tpocorre
                             ,crapcct.vltarifa
                             ,crapcct.cdtarhis
                             ,crapcct.cdoperad
                             ,crapcct.dtaltera
                             ,crapcct.hrtransa)
                       VALUES(vr_cdcooper
                             ,pr_nrconven
                             ,pr_cddbanco
                             ,rw_crapoco.cdocorre
                             ,rw_crapoco.tpocorre
                             ,0
                             ,0
                             ,vr_cdoperad
                             ,to_date(pr_dtmvtolt,'DD/MM/RRRR')
                             ,GENE0002.fn_busca_time);                          
                                    
        END LOOP; 
        
      EXCEPTION 
        WHEN OTHERS THEN        
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel incluir o(s) registro(s) de tarifas do convenio.';
          
          RAISE vr_exc_erro;
          
      END;
      
    END IF;
                     
    pc_gera_log (pr_cdcooper => vr_cdcooper
                ,pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 1
                ,pr_nrconven => pr_nrconven
                ,pr_dsdcampo => ''
                ,pr_vlrcampo => ''
                ,pr_vlcampo2 => ''
                ,pr_des_erro => pr_des_erro);                                                  
    
    pr_des_erro := 'OK';
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN 
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
      pr_nmdcampo:= vr_nmdcampo;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');  
                                     
      ROLLBACK;
                                                                                                     
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_inclusao --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
      ROLLBACK;   
  
  END pc_inclusao;                      
 
  PROCEDURE pc_consulta_tarifas(pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                               ,pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco                              
                               ,pr_dsdepart IN VARCHAR2              --Departamento
                               ,pr_cddopcao IN VARCHAR2              --Opção
                               ,pr_nmdatela IN VARCHAR2              --Nome da tela
                               ,pr_nrregist IN INTEGER               -- Número de registros
                               ,pr_nriniseq IN INTEGER               -- Número sequencial 
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_consulta_tarifas                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Marco/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca tarifas da cobranca
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
    --Cursor para buscar as tarifas
    CURSOR cr_crapcct(pr_cdcooper IN crapcct.cdcooper%TYPE
                     ,pr_nrconven IN crapcct.nrconven%TYPE
                     ,pr_cddbanco IN crapcct.cddbanco%TYPE)IS
    SELECT crapcct.cdcooper
          ,crapcct.cddbanco
          ,crapcct.nrconven
          ,crapcct.cdocorre
          ,crapoco.dsocorre
          ,crapcct.tpocorre
          ,crapcct.vltarifa
          ,crapcct.cdtarhis
          ,decode(crapcct.tpocorre,1,'REM','RET') axocorre
      FROM crapcct
          ,crapoco
     WHERE crapcct.cdcooper = pr_cdcooper
       AND crapcct.nrconven = pr_nrconven
       AND crapcct.cddbanco = pr_cddbanco
       AND crapoco.cdcooper = crapcct.cdcooper
       AND crapoco.cdocorre = crapcct.cdocorre
       AND crapoco.tpocorre = crapcct.tpocorre
       AND crapoco.cddbanco = crapcct.cddbanco
       AND crapoco.flgativo = 1;       
    rw_crapcct cr_crapcct%ROWTYPE;
    
    --Cursor para encontrar o convenio
    CURSOR cr_crapcco(pr_cdcooper IN crapcco.cdcooper%TYPE
                     ,pr_nrconven IN crapcco.nrconven%TYPE
                     ,pr_cddbanco IN crapcco.cddbanco%TYPE)IS
    SELECT crapcco.cdcooper
          ,crapcco.cddbanco
          ,crapcco.nrconven
          ,crapcco.flgregis
      FROM crapcco
     WHERE crapcco.cdcooper = pr_cdcooper
       AND crapcco.nrconven = pr_nrconven
       AND crapcco.cddbanco = pr_cddbanco;
    rw_crapcco cr_crapcco%ROWTYPE;
                     
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';   
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;  
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCCO'
                              ,pr_action => null); 
                                
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    OPEN cr_crapcco(pr_cdcooper => vr_cdcooper
                   ,pr_nrconven => pr_nrconven
                   ,pr_cddbanco => pr_cddbanco);
                   
    FETCH cr_crapcco INTO rw_crapcco;
    
    IF cr_crapcco%NOTFOUND THEN
      
      --Fecha o cursor
      CLOSE cr_crapcco;
      
      --Monta mensagem de critica
      vr_cdcritic := 563;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      
      RAISE vr_exc_erro;
    
    END IF; 
    
    --Fecha o cursor
    CLOSE cr_crapcco;              
         
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><tarifas>');     
      
    IF rw_crapcco.flgregis > 0 THEN 
                            
      FOR rw_crapcct IN cr_crapcct(pr_cdcooper => vr_cdcooper
                                  ,pr_nrconven => pr_nrconven
                                  ,pr_cddbanco => pr_cddbanco) LOOP   
                                                         
        --Incrementar contador
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
        -- controles da paginacao 
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

          --Proximo
          CONTINUE;  
                  
        END IF; 
              
        IF vr_nrregist >= 1 THEN   
          -- Carrega os dados           
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<tarifa>'||                                                                                                        
                                                         '  <cdcooper>' || rw_crapcct.cddbanco ||'</cdcooper>'||
                                                         '  <cddbanco>' || rw_crapcct.cddbanco ||'</cddbanco>'||
                                                         '  <nrconven>' || rw_crapcct.nrconven ||'</nrconven>'||
                                                         '  <cdocorre>' || rw_crapcct.cdocorre ||'</cdocorre>'||
                                                         '  <dsocorre>' || rw_crapcct.dsocorre ||'</dsocorre>'|| 
                                                         '  <tpocorre>' || rw_crapcct.tpocorre ||'</tpocorre>'||
                                                         '  <axocorre>' || rw_crapcct.axocorre ||'</axocorre>'||
                                                         '  <vltarifa>' || rw_crapcct.vltarifa ||'</vltarifa>'||
                                                         '  <cdtarhis>' || rw_crapcct.cdtarhis ||'</cdtarhis>'||
                                                       '</tarifa>');
        
          --Diminuir registros
          vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
        END IF;         
          
        vr_contador := vr_contador + 1; 
                                                                                                         
      END LOOP;      
    
    END IF;
                
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</tarifas></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
          
    pr_des_erro := 'OK';
       
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      ROLLBACK;
    
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      ROLLBACK;
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_tarifas --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_consulta_tarifas;  
   
  PROCEDURE pc_consulta_motivos(pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_nrconven IN crapcct.nrconven%TYPE --Convenio
                               ,pr_cddbanco IN crapcct.cddbanco%TYPE --Banco
                               ,pr_cdocorre IN crapcct.cdocorre%TYPE --Ocorrencia                               
                               ,pr_dsdepart IN VARCHAR2              --Departamento
                               ,pr_cddopcao IN VARCHAR2              --Opção
                               ,pr_nmdatela IN VARCHAR2              --Nome da tela
                               ,pr_nrregist IN INTEGER               -- Número de registros
                               ,pr_nriniseq IN INTEGER               -- Número sequencial 
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_consulta_motivos                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Abril/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca motivos
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
    
    --Cursor para pegar os motivos
    CURSOR cr_crapmot(pr_cdcooper IN crapmot.cdcooper%TYPE
                     ,pr_cddbanco IN crapmot.cddbanco%TYPE 
                     ,pr_nrconven IN crapcct.nrconven%TYPE                   
                     ,pr_cdocorre IN crapmot.cdocorre%TYPE)IS
    SELECT crapmot.cdmotivo
          ,crapmot.dsmotivo
          ,crapctm.vltarifa
          ,crapctm.cdtarhis
          ,crapctm.cddbanco  
          ,crapctm.cdocorre
          ,crapctm.tpocorre       
     FROM crapctm
         ,crapmot
    WHERE crapctm.cdcooper = pr_cdcooper
      AND crapctm.cddbanco = pr_cddbanco
      AND crapctm.nrconven = pr_nrconven
      AND crapctm.cdocorre = pr_cdocorre
      AND crapctm.tpocorre = 2
      AND crapmot.cdcooper = crapctm.cdcooper
      AND crapmot.cddbanco = crapctm.cddbanco
      AND crapmot.cdocorre = crapctm.cdocorre
      AND crapmot.tpocorre = crapctm.tpocorre
      AND crapmot.cdmotivo = crapctm.cdmotivo;
    rw_crapmot cr_crapmot%ROWTYPE;
                     
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';  
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;    
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCCO'
                              ,pr_action => null); 
                                 
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><motivos>');     
                                              
    FOR rw_crapmot IN cr_crapmot(pr_cdcooper => vr_cdcooper
                                ,pr_cddbanco => pr_cddbanco 
                                ,pr_nrconven => pr_nrconven
                                ,pr_cdocorre => pr_cdocorre) LOOP
      
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
            
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                
      END IF; 
            
      IF vr_nrregist >= 1 THEN 
          
        -- Carrega os motivos        
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<motivo>'||                                                       
                                                     '  <cdmotivo>' || rw_crapmot.cdmotivo ||'</cdmotivo>'||
                                                     '  <dsmotivo>' || rw_crapmot.dsmotivo ||'</dsmotivo>'||
                                                     '  <vltarifa>' || rw_crapmot.vltarifa ||'</vltarifa>'||
                                                     '  <cdtarhis>' || rw_crapmot.cdtarhis ||'</cdtarhis>'||                                                                                                                                               
                                                     '  <cddbanco>' || rw_crapmot.cddbanco ||'</cddbanco>'||                                                                                                                                               
                                                     '  <cdocorre>' || rw_crapmot.cdocorre ||'</cdocorre>'||                                                                                                                                               
                                                     '  <tpocorre>' || rw_crapmot.tpocorre ||'</tpocorre>'||                                                                                                                                                                                                  
                                                     '</motivo>');    
    
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
         
      END IF;         
        
      vr_contador := vr_contador + 1; 
                       
    END LOOP;
                 
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</motivos></Root>'
                           ,pr_fecha_xml      => TRUE);
                    
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob); 
    
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;  
    
    pr_des_erro := 'OK';
        
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      ROLLBACK;
    
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      ROLLBACK;
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_consulta_motivos --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_consulta_motivos;  
   
  PROCEDURE pc_atualiza_motivos(pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_nrconven IN crapctm.nrconven%TYPE --Convenio
                               ,pr_dsdepart IN VARCHAR2              --Departamento
                               ,pr_cddopcao IN VARCHAR2              --Opção
                               ,pr_nmdatela IN VARCHAR2              --Nome da tela
                               ,pr_vlmotivo IN VARCHAR2              --Motivos
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_atualiza_motivos                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Abril/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Atualiza motivos
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
    
    --Cursor para pegar os motivos
    CURSOR cr_crapctm(pr_cdcooper IN crapctm.cdcooper%TYPE
                     ,pr_cddbanco IN crapctm.cddbanco%TYPE 
                     ,pr_nrconven IN crapctm.cdocorre%TYPE
                     ,pr_cdocorre IN crapctm.cdocorre%TYPE
                     ,pr_cdmotivo IN crapctm.cdmotivo%TYPE)IS
    SELECT crapctm.cdcooper
          ,crapctm.cddbanco
          ,crapctm.nrconven
          ,crapctm.cdocorre    
          ,crapctm.vltarifa
          ,crapctm.cdtarhis      
     FROM crapctm
    WHERE crapctm.cdcooper = pr_cdcooper
      AND crapctm.cddbanco = pr_cddbanco
      AND crapctm.nrconven = pr_nrconven
      AND crapctm.cdocorre = pr_cdocorre
      AND crapctm.cdmotivo = pr_cdmotivo
      AND crapctm.tpocorre = 2;
    rw_crapctm cr_crapctm%ROWTYPE;
    rw_crapctm_new cr_crapctm%ROWTYPE;
                    
    --Cursor para encontrar o histórico 
    CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE
                     ,pr_cdhistor IN craphis.cdhistor%TYPE)IS
    SELECT craphis.cdcooper
      FROM craphis
     WHERE craphis.cdcooper = pr_cdcooper
       AND craphis.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%ROWTYPE;  
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;
    
    --> Tabela de registros atualizados
    vr_tab_registros TELA_CADCCO.typ_tab_registros;
    
    vr_split gene0002.typ_split := gene0002.typ_split();
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais 
    vr_cdocorre crapctm.cdocorre%TYPE;
    vr_cddbanco crapctm.cddbanco%TYPE;
    vr_cdmotivo crapctm.cdmotivo%TYPE;
    vr_vltarifa crapctm.vltarifa%TYPE;
    vr_cdtarhis crapctm.cdtarhis%TYPE; 
    vr_index PLS_INTEGER := 0;  
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
    -- Variável exceção para locke
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);
  
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCCO'
                              ,pr_action => null); 
                                   
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
           
    -- Quebrar valores da lista recebida como parametro
    IF TRIM(pr_vlmotivo) IS NOT NULL THEN
      
      vr_split := gene0002.fn_quebra_string(pr_string  => pr_vlmotivo
                                          , pr_delimit => '#');
                                          
      -- ler linhas
      FOR i IN vr_split.first..vr_split.last LOOP
               
        vr_cddbanco := ( gene0002.fn_busca_entrada( pr_postext => 1
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));
                                                                                     
        vr_cdocorre := ( gene0002.fn_busca_entrada( pr_postext => 2
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));
        
        vr_cdmotivo := ( gene0002.fn_busca_entrada( pr_postext => 3
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));
                                                                                            
        vr_vltarifa := TO_NUMBER(REPLACE(gene0002.fn_busca_entrada( pr_postext => 4
                                                                   ,pr_dstext  => vr_split(i)
                                                                   ,pr_delimitador => '|'),'.',','));
                                                                                                              
        vr_cdtarhis := ( gene0002.fn_busca_entrada( pr_postext => 5
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));  
        
        OPEN cr_craphis(pr_cdcooper => vr_cdcooper
                       ,pr_cdhistor => vr_cdtarhis);
                       
        FETCH cr_craphis INTO rw_craphis;
        
        IF cr_craphis%NOTFOUND THEN
          
          --Fecha o cursor
          CLOSE cr_craphis;
          
          vr_cdcritic := 93; 
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
                             
          RAISE vr_exc_erro;
          
        ELSE
          
          --Fecha o cursor
          CLOSE cr_craphis;
          
        END IF;
                                                   
        BEGIN
          -- Busca associado
          OPEN cr_crapctm(pr_cdcooper => vr_cdcooper
                         ,pr_cddbanco => vr_cddbanco
                         ,pr_nrconven => pr_nrconven
                         ,pr_cdocorre => vr_cdocorre
                         ,pr_cdmotivo => vr_cdmotivo);
                          
          FETCH cr_crapctm INTO rw_crapctm;
               
          -- Gerar erro caso não encontre
          IF cr_crapctm%NOTFOUND THEN
            
            -- Fechar cursor pois teremos raise
            CLOSE cr_crapctm;
             
             --MOnta mensagem de erro
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel atualizar a tarifa do motivo.';
             
             -- Gera exceção
             RAISE vr_exc_erro;
             
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapctm;
          END IF; 
            
        EXCEPTION
          WHEN vr_exc_locked THEN
            gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPCTM'
                                ,pr_nrdrecid    => ''
                                ,pr_des_reto    => pr_des_erro
                                ,pt_tab_locktab => vr_tab_locktab);
                                
            IF pr_des_erro = 'OK' THEN
              FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
                vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPCTM)' || 
                               ' - ' || vr_tab_locktab(VR_IND).nmusuari;
              END LOOP;
            END IF;
            
            RAISE vr_exc_erro;
             
        END;  
        
        --Realiza a alteração do registro de convenio                          
        BEGIN
          
          UPDATE crapctm SET crapctm.vltarifa = vr_vltarifa
                            ,crapctm.cdtarhis = vr_cdtarhis
                      WHERE crapctm.cdcooper = vr_cdcooper
                        AND crapctm.cddbanco = vr_cddbanco
                        AND crapctm.nrconven = pr_nrconven
                        AND crapctm.cdocorre = vr_cdocorre
                        AND crapctm.tpocorre = 2
                  RETURNING crapctm.cdcooper
                           ,crapctm.cddbanco
                           ,crapctm.vltarifa
                           ,crapctm.cdtarhis  
                      INTO rw_crapctm_new.cdcooper
                          ,rw_crapctm_new.cddbanco
                          ,rw_crapctm_new.vltarifa
                          ,rw_crapctm_new.cdtarhis;
                          
                          
        EXCEPTION
          WHEN OTHERS THEN      
            --Monta mensagem de erro
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel atualizar a tarifa do motivo - ' || sqlerrm;
            
            RAISE vr_exc_erro;             
        
        END; 
         
        -- Captura último indice da PL Table
        vr_index := nvl(vr_tab_registros.count, 0) + 1;
          
        -- Gravando registros       
        vr_tab_registros(vr_index).avltarifa := rw_crapctm.vltarifa;
        vr_tab_registros(vr_index).acdtarhis := rw_crapctm.cdtarhis;
        vr_tab_registros(vr_index).nvltarifa := rw_crapctm_new.vltarifa;
        vr_tab_registros(vr_index).ncdtarhis := rw_crapctm_new.cdtarhis;
                                              
      END LOOP;
        
    END IF;
    
    --Buscar registro
    vr_index:= vr_tab_registros.FIRST;
        
    --Percorrer todos os registros
    WHILE vr_index IS NOT NULL LOOP
        
      IF vr_tab_registros(vr_index).avltarifa <> vr_tab_registros(vr_index).nvltarifa THEN
        pc_gera_log (pr_cdcooper => vr_cdcooper
                    ,pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 4
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Valor da tarifa'
                    ,pr_vlrcampo => TRIM(TO_CHAR(vr_tab_registros(vr_index).avltarifa, 'fm999g990d00'))
                    ,pr_vlcampo2 => TRIM(TO_CHAR(vr_tab_registros(vr_index).nvltarifa, 'fm999g990d00'))
                    ,pr_des_erro => pr_des_erro);
                     
      END IF;
      
      IF vr_tab_registros(vr_index).acdtarhis <> vr_tab_registros(vr_index).ncdtarhis THEN
        pc_gera_log (pr_cdcooper => vr_cdcooper
                    ,pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 4
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Historico'
                    ,pr_vlrcampo => vr_tab_registros(vr_index).acdtarhis
                    ,pr_vlcampo2 => vr_tab_registros(vr_index).ncdtarhis
                    ,pr_des_erro => pr_des_erro);
                     
      END IF;  
      
      --Proximo Registro
      vr_index:= vr_tab_registros.NEXT(vr_index);
                   
    END LOOP;
                  
    pr_des_erro := 'OK';
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      ROLLBACK;
    
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      ROLLBACK;
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_atualiza_motivos --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_atualiza_motivos;  

  PROCEDURE pc_atualiza_tarifas(pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_nrconven IN crapctm.nrconven%TYPE --Convenio
                               ,pr_vltarifa IN VARCHAR2              --Tarifas
                               ,pr_dsdepart IN VARCHAR2              --Departamento
                               ,pr_cddopcao IN VARCHAR2              --Opção
                               ,pr_nmdatela IN VARCHAR2              --Nome da tela
                               ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                               ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_atualiza_tarifas                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan - RKAM
    Data     : Abril/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Atualiza as tarifas motivos
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
    
    --Cursor para pegar os motivos
    CURSOR cr_crapcct(pr_cdcooper IN crapcct.cdcooper%TYPE                      
                     ,pr_nrconven IN crapcct.nrconven%TYPE
                     ,pr_cdocorre IN crapcct.cdocorre%TYPE
                     ,pr_tpocorre IN crapcct.tpocorre%TYPE)IS
    SELECT crapcct.cdcooper
          ,crapcct.cddbanco
          ,crapcct.nrconven
          ,crapcct.cdocorre
          ,crapcct.vltarifa
          ,crapcct.cdtarhis          
     FROM crapcct
    WHERE crapcct.cdcooper = pr_cdcooper
      AND crapcct.nrconven = pr_nrconven
      AND crapcct.cdocorre = pr_cdocorre
      AND crapcct.tpocorre = pr_tpocorre;
    rw_crapcct cr_crapcct%ROWTYPE;
    rw_crapcct_new cr_crapcct%ROWTYPE;
                    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;
    
    --> Tabela de registros atualizados
    vr_tab_registros TELA_CADCCO.typ_tab_registros;
    
    vr_split gene0002.typ_split := gene0002.typ_split();
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais       
    vr_cdocorre crapcct.cdocorre%TYPE;
    vr_tpocorre crapcct.tpocorre%TYPE;
    vr_vltarifa crapcct.vltarifa%TYPE;
    vr_cdtarhis crapcct.cdtarhis%TYPE;
    vr_index PLS_INTEGER := 0;  
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
    -- Variável exceção para locke
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);
      
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'CADCCO'
                              ,pr_action => null); 
                                 
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
       
    -- Quebrar valores da lista recebida como parametro
    IF TRIM(pr_vltarifa) IS NOT NULL THEN
      vr_split := gene0002.fn_quebra_string(pr_string  => pr_vltarifa
                                          , pr_delimit => '#');
      -- ler linhas
      FOR i IN vr_split.first..vr_split.last LOOP
                                                   
        vr_cdocorre := ( gene0002.fn_busca_entrada( pr_postext => 1
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));
          
        vr_tpocorre := ( gene0002.fn_busca_entrada( pr_postext => 2
                                                   ,pr_dstext  => vr_split(i)
                                                   ,pr_delimitador => '|'));
                                                 
        vr_vltarifa := TO_NUMBER(REPLACE(gene0002.fn_busca_entrada( pr_postext => 3
                                                                   ,pr_dstext  => vr_split(i)
                                                                   ,pr_delimitador => '|'),'.',','));
                                        
        vr_cdtarhis := ( gene0002.fn_busca_entrada( pr_postext => 4
                                                 ,pr_dstext  => vr_split(i)
                                                 ,pr_delimitador => '|'));  
        
        BEGIN
          -- Busca associado
          OPEN cr_crapcct(pr_cdcooper => vr_cdcooper
                         ,pr_nrconven => pr_nrconven
                         ,pr_cdocorre => vr_cdocorre
                         ,pr_tpocorre => vr_tpocorre);
                          
          FETCH cr_crapcct INTO rw_crapcct;
               
          -- Gerar erro caso não encontre
          IF cr_crapcct%NOTFOUND THEN
            
            -- Fechar cursor pois teremos raise
            CLOSE cr_crapcct;
             
             --MOnta mensagem de erro
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel atualizar a tarifa da cobranca.';
             
             -- Gera exceção
             RAISE vr_exc_erro;
             
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapcct;
          END IF; 
            
        EXCEPTION
          WHEN vr_exc_locked THEN
            gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPCCT'
                                ,pr_nrdrecid    => ''
                                ,pr_des_reto    => pr_des_erro
                                ,pt_tab_locktab => vr_tab_locktab);
                                
            IF pr_des_erro = 'OK' THEN
              FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
                vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPCCT)' || 
                               ' - ' || vr_tab_locktab(VR_IND).nmusuari;
              END LOOP;
            END IF;
            
            RAISE vr_exc_erro;
             
        END;  
        
        --Realiza a alteração do registro de convenio                          
        BEGIN
          
          UPDATE crapcct SET crapcct.vltarifa = vr_vltarifa
                            ,crapcct.cdtarhis = vr_cdtarhis
                       WHERE crapcct.cdcooper = vr_cdcooper
                         AND crapcct.nrconven = pr_nrconven
                         AND crapcct.cdocorre = vr_cdocorre
                         AND crapcct.tpocorre = vr_tpocorre
                   RETURNING crapcct.cdcooper
                            ,crapcct.cddbanco
                            ,crapcct.vltarifa
                            ,crapcct.cdtarhis  
                       INTO rw_crapcct_new.cdcooper
                           ,rw_crapcct_new.cddbanco
                           ,rw_crapcct_new.vltarifa
                           ,rw_crapcct_new.cdtarhis;
                          
                          
        EXCEPTION
          WHEN OTHERS THEN      
            --Monta mensagem de erro
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel atualizar a tarifa da cobranca - ' || sqlerrm;
            
            RAISE vr_exc_erro;             
        
        END;                                     
         
        -- Captura último indice da PL Table
        vr_index := nvl(vr_tab_registros.count, 0) + 1;
          
        -- Gravando registros       
        vr_tab_registros(vr_index).avltarifa := rw_crapcct.vltarifa;
        vr_tab_registros(vr_index).acdtarhis := rw_crapcct.cdtarhis;
        vr_tab_registros(vr_index).nvltarifa := rw_crapcct_new.vltarifa;
        vr_tab_registros(vr_index).ncdtarhis := rw_crapcct_new.cdtarhis;
                                                  
      END LOOP;
        
    END IF;
      
    --Buscar registro
    vr_index:= vr_tab_registros.FIRST;
        
    --Percorrer todos os registros
    WHILE vr_index IS NOT NULL LOOP
        
      IF vr_tab_registros(vr_index).avltarifa <> vr_tab_registros(vr_index).nvltarifa THEN
        pc_gera_log (pr_cdcooper => vr_cdcooper
                    ,pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 5
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Valor da tarifa' 
                    ,pr_vlrcampo => TRIM(TO_CHAR(vr_tab_registros(vr_index).avltarifa, 'fm999g990d00')) 
                    ,pr_vlcampo2 => TRIM(TO_CHAR(vr_tab_registros(vr_index).nvltarifa, 'fm999g990d00')) 
                    ,pr_des_erro => pr_des_erro);
                     
      END IF;
      
      IF vr_tab_registros(vr_index).acdtarhis <> vr_tab_registros(vr_index).ncdtarhis THEN
        pc_gera_log (pr_cdcooper => vr_cdcooper
                    ,pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 5
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Historico'
                    ,pr_vlrcampo => vr_tab_registros(vr_index).acdtarhis
                    ,pr_vlcampo2 => vr_tab_registros(vr_index).ncdtarhis
                    ,pr_des_erro => pr_des_erro);
                     
      END IF;  
      
      --Proximo Registro
      vr_index:= vr_tab_registros.NEXT(vr_index);
                   
    END LOOP;
    
    pr_des_erro := 'OK';
    
    COMMIT;
       
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      ROLLBACK;
    
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      ROLLBACK;
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_atualiza_tarifas --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_atualiza_tarifas;  
  

END TELA_CADCCO;
/
