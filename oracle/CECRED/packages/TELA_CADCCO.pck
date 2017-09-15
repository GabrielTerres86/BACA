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
    
	PROCEDURE pc_valida_informacoes_web(pr_nrconven IN crapcco.nrconven%TYPE --Convenio
																		,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco
																		,pr_nrdctabb IN crapcco.nrdctabb%TYPE --Conta base
																		,pr_cdbccxlt IN crapcco.cdbccxlt%TYPE --Caixa/lote
																		,pr_cdagenci IN crapcco.cdagenci%TYPE --Agencia
																		,pr_nrdolote IN crapcco.nrdolote%TYPE --Lote
																		,pr_cdhistor IN crapcco.cdhistor%TYPE --Histórico
																		,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
																		,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
																		,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
																		,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
																		,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
																		,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
																		,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
																		,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
																		,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
																		,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
																		,pr_dtmvtolt VARCHAR2                 --Data de movimento                       
																		,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
																		,pr_flprotes IN crapcco.flprotes%TYPE --Usar opção protesto
																		,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
																		,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Permitir uso de float de
																		,pr_qtfltate IN crapcco.qtfltate%TYPE --Permitir uso de float até
																		,pr_qtdecini IN crapcco.qtdecini%TYPE --Usar descurso de prazo de
																		,pr_qtdecate IN crapcco.qtdecate%TYPE --Usar descurso de prazo até
																		,pr_fldctman IN crapcco.fldctman%TYPE --Permite desconto manual
																		,pr_perdctmx IN crapcco.perdctmx%TYPE --Percentual máximo de desconto manual
																		,pr_flgapvco IN crapcco.flgapvco%TYPE --Aprovação do coordenador
																		,pr_flrecipr IN crapcco.flrecipr%TYPE --Usar reciprocidade
																		,pr_cddepart IN VARCHAR2              --Departamento
																		,pr_cddopcao IN VARCHAR2              --Opção da tela
																		,pr_nmdatela IN VARCHAR2              --Nome da tela                          
																		,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
																		,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
																		,pr_dscritic OUT VARCHAR2             --Descrição da crítica
																		,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
																		,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
																		,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK


	
  PROCEDURE pc_consulta(pr_nrconven  IN crapcco.nrconven%TYPE -- Convenio
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
                        ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                        ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                        ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                        ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                        ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                        ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                        ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                        ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                        ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                        ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                        ,pr_dtmvtolt IN VARCHAR2              --Data de movimento
                        ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
												,pr_flprotes IN crapcco.flprotes%TYPE --Usar opção protesto
                        ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
                        ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Permitir uso de float de
                        ,pr_qtfltate IN crapcco.qtfltate%TYPE --Permitir uso de float até
                        ,pr_qtdecini IN crapcco.qtdecini%TYPE --Usar descurso de prazo de
                        ,pr_qtdecate IN crapcco.qtdecate%TYPE --Usar descurso de prazo até
                        ,pr_fldctman IN crapcco.fldctman%TYPE --Permite desconto manual
                        ,pr_perdctmx IN crapcco.perdctmx%TYPE --Percentual máximo de desconto manual
                        ,pr_flgapvco IN crapcco.flgapvco%TYPE --Aprovação do coordenador
                        ,pr_flrecipr IN crapcco.flrecipr%TYPE --Usar reciprocidade
                        ,pr_idprmrec IN crapcco.idprmrec%TYPE --Id da parametrização da reciprocidade cirada na CONFRP
                        ,pr_cdagedbb IN crapcco.cdagedbb%TYPE --Codigo da agencia no Banco do Brasil
                        ,pr_dslogcfg IN VARCHAR2              --Log das operações na tela CONFRP
                        ,pr_cddepart IN VARCHAR2              --Departamento
                        ,pr_cddopcao IN VARCHAR2              --Opção da tela
                        ,pr_nmdatela IN VARCHAR2              --Nome da tela                        
                        ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK                                 
												
  PROCEDURE pc_exclusao (pr_nrconven  IN crapcco.nrconven%TYPE   --Convenio
                        ,pr_dtmvtolt  IN VARCHAR2                --Data de movimento 
                        ,pr_cddopcao  IN VARCHAR                 --Opção
                        ,pr_cddepart  IN VARCHAR                 --Departamento
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
                        ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                        ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                        ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                        ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                        ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                        ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                        ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                        ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                        ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                        ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                        ,pr_dtmvtolt VARCHAR2                 --Data de movimento                       
                        ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
												,pr_flprotes IN crapcco.flprotes%TYPE --Usar opção protesto
                        ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
                        ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Permitir uso de float de
                        ,pr_qtfltate IN crapcco.qtfltate%TYPE --Permitir uso de float até
                        ,pr_qtdecini IN crapcco.qtdecini%TYPE --Usar descurso de prazo de
                        ,pr_qtdecate IN crapcco.qtdecate%TYPE --Usar descurso de prazo até
                        ,pr_fldctman IN crapcco.fldctman%TYPE --Permite desconto manual
                        ,pr_perdctmx IN crapcco.perdctmx%TYPE --Percentual máximo de desconto manual
                        ,pr_flgapvco IN crapcco.flgapvco%TYPE --Aprovação do coordenador
                        ,pr_flrecipr IN crapcco.flrecipr%TYPE --Usar reciprocidade
                        ,pr_idprmrec IN crapcco.idprmrec%TYPE --Id da parametrização da reciprocidade cirada na CONFRP
                        ,pr_cdagedbb IN crapcco.cdagedbb%TYPE --Codigo da agencia no Banco do Brasil
                        ,pr_dslogcfg IN VARCHAR2              --Log das operações na tela CONFRP
                        ,pr_cddepart IN VARCHAR2              --Departamento
                        ,pr_cddopcao IN VARCHAR2              --Opção da tela
                        ,pr_nmdatela IN VARCHAR2              --Nome da tela                        
                        ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                        ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
   
  PROCEDURE pc_consulta_tarifas(pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                               ,pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco                              
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
   Data    : Marco/2016                       Ultima atualizacao: 19/10/2016

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Cadastro Parametros Sistema de Cobranca.

   Alteracoes: 27/04/2016 - Ajuste para liberar acesso para departamento
                            CANAIS a tela CADCCO, conforme solicitado
                            no chamado 441903. (Kelvin)                                       
                            
               19/10/2016 - Remover validação de verificação se já exite um 
                            convenio para internet na mesma cooperativa na
                            procedure pc_valida_informacoes (Lucas Ranghetti #531199)
                              
               28/11/2016 - P341 - Automatização BACENJUD - Alterado o parametro PR_DSDEPART 
                            para PR_CDDEPART e as consultas do fonte para utilizar o código 
                            do departamento nas validações (Renato Darosci - Supero)
  ---------------------------------------------------------------------------------------------------------------*/

  -- Variavel temporária para LOG 
  vr_dslogtel VARCHAR2(32767) := '';
  
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
  
  PROCEDURE pc_gera_log(pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_tipdolog IN INTEGER 
                       ,pr_nrconven IN crapcco.nrconven%TYPE
                       ,pr_dsdcampo IN VARCHAR2
                       ,pr_vlrcampo IN VARCHAR2
                       ,pr_vlcampo2 IN VARCHAR2) IS  
                        
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
         vr_dslogtel := vr_dslogtel 
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                     || ' -->  Operador '|| pr_cdoperad || ' - ' 
                     || 'Incluiu o convenio de cobranca ' || pr_nrconven || '.';
       WHEN 6 THEN
         vr_dslogtel := vr_dslogtel 
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                     || ' -->  Operador '|| pr_cdoperad || ' - ' 
                     || 'Incluiu campo ' || pr_dsdcampo 
                     || ' com valor ' || pr_vlrcampo || '.';
       WHEN 2 THEN
         vr_dslogtel := vr_dslogtel 
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                     || ' -->  Operador '|| pr_cdoperad || ' - ' 
                     || 'Alterou o campo ' || pr_dsdcampo 
                     || ' de ' || pr_vlrcampo || ' para ' || pr_vlcampo2 || '.';
       WHEN 7 THEN
         vr_dslogtel := vr_dslogtel 
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                     || ' -->  Operador '|| pr_cdoperad || ' - ' 
                     || 'Alterou o convenio de cobranca ' 
                     || pr_nrconven ||'.';
       WHEN 3 THEN
         vr_dslogtel := vr_dslogtel 
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                     || ' -->  Operador '|| pr_cdoperad || ' - ' 
                     || 'Excluiu o convenio de cobranca ' 
                     || pr_nrconven || '.';
       WHEN 4 THEN
         vr_dslogtel := vr_dslogtel 
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                     || ' -->  Operador '|| pr_cdoperad || ' - ' 
                     || 'Alterou a tarifa do motivo de cobranca do convenio ' 
                     || pr_nrconven || ', campo ' || pr_dsdcampo
                     || ' de ' || pr_vlrcampo || ' para ' || pr_vlcampo2 || '.';
       WHEN 5 THEN
         vr_dslogtel := vr_dslogtel 
                     || to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') 
                     || ' -->  Operador '|| pr_cdoperad || ' - '
                     || 'Alterou a tarifa de cobranca do convenio ' 
                     || pr_nrconven || ', campo ' || pr_dsdcampo 
                     || ' de ' || pr_vlrcampo || ' para ' || pr_vlcampo2 || '.';
                                                                                                                                                                                                    
       ELSE NULL;
       
     END CASE; 
        
     -- Incluir quebra de linha
     vr_dslogtel := vr_dslogtel || chr(10);
   
   EXCEPTION
     WHEN OTHERS THEN         
       -- Não havia tratamento anterior no retorno da mesma
       NULL;    
   END pc_gera_log; 
   
   PROCEDURE pc_gera_log_arquivo(pr_cdcooper IN crapcop.cdcooper%TYPE
                                ,pr_dscritic OUT VARCHAR2) IS  
                        
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_gera_log_arquivo                            antiga: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Marcos - Supero
    Data     : Maio/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para gerar log da memória no arquivo
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                            
   
   BEGIN
     
     btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                               ,pr_ind_tipo_log => 2 -- Erro tratato
                               ,pr_nmarqlog     => 'cadcco.log'
                               ,pr_des_log      => rtrim(vr_dslogtel,chr(10)));
   EXCEPTION
    WHEN OTHERS THEN   
      
      pr_dscritic := 'Erro ao gravar LOG: '||SQLERRM;    
         
   END pc_gera_log_arquivo;    
   
   PROCEDURE pc_valida_informacoes(pr_cdcooper IN crapcop.cdcooper%TYPE --Código da cooperativa
                                  ,pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                                  ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco
                                  ,pr_nrdctabb IN crapcco.nrdctabb%TYPE --Conta base
                                  ,pr_cdbccxlt IN crapcco.cdbccxlt%TYPE --Caixa/lote
                                  ,pr_cdagenci IN crapcco.cdagenci%TYPE --Agencia
                                  ,pr_nrdolote IN crapcco.nrdolote%TYPE --Lote
                                  ,pr_cdhistor IN crapcco.cdhistor%TYPE --Histórico
                                  ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                                  ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                                  ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                                  ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                                  ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                                  ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                                  ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                                  ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                                  ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                                  ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                                  ,pr_dtmvtolt VARCHAR2                 --Data de movimento                       
                                  ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
																	,pr_flprotes IN crapcco.flprotes%TYPE --Usar opção protesto
																	,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
																	,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Permitir uso de float de
																	,pr_qtfltate IN crapcco.qtfltate%TYPE --Permitir uso de float até
																	,pr_qtdecini IN crapcco.qtdecini%TYPE --Usar descurso de prazo de
																	,pr_qtdecate IN crapcco.qtdecate%TYPE --Usar descurso de prazo até
																	,pr_fldctman IN crapcco.fldctman%TYPE --Permite desconto manual
																	,pr_perdctmx IN crapcco.perdctmx%TYPE --Percentual máximo de desconto manual
																	,pr_flgapvco IN crapcco.flgapvco%TYPE --Aprovação do coordenador
																	,pr_flrecipr IN crapcco.flrecipr%TYPE --Usar reciprocidade
                                  ,pr_cddepart IN VARCHAR2              --Departamento
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
    Data     : Marco/2016                           Ultima atualizacao: 19/10/2016
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Realiza a validação das informações para cadastro/alteração do registro de convenio
    
    Alterações : 19/10/2016 - Remover validação de verificação se já exite um 
                              convenio para internet na mesma cooperativa 
                              (Lucas Ranghetti #531199)
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
        
    IF pr_cddepart NOT IN (1,18,20) THEN 
       
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
        vr_dscritic := 'Ha boleto(s) ativo(s) para este convenio!';
        
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
		
		-- Valida se Valor do float "de" é maior que "até"
		IF (pr_qtdfloat > pr_qtfltate) THEN
			
			 vr_cdcritic := 0;
			 vr_dscritic := 'Valor inválido para o Uso de Float. Verificar a Faixa de - até!';
			 pr_nmdcampo := 'qtdfloat';
			 
			 RAISE vr_exc_erro;
    END IF;
		
		-- Valida se Valor do decurso de prazo foi informado
		IF (pr_qtdecini IS NULL OR 
        pr_qtdecate IS NULL) THEN
			
			 vr_cdcritic := 0;
			 vr_dscritic := 'Favor preencher período inicial e final para Decurso de Prazo!';
			 pr_nmdcampo := 'qtdecini';
			 
			 RAISE vr_exc_erro;
		END IF;
		
		-- Valida se Valor do decurso de prazo "de" é maior que "até"
		IF (pr_qtdecini > pr_qtdecate) THEN
			
			 vr_cdcritic := 0;
			 vr_dscritic := 'Valor inválido para o Decurso de prazo. Verificar a Faixa de - até!';
			 pr_nmdcampo := 'qtdecini';
			 
			 RAISE vr_exc_erro;
		END IF;
		
		-- Se foi informado um percentual de desconto manual e não estiver habilito a opção de usar desconto manual
		-- ou 
		-- Se não foi informado um percentual de desconto manual e estiver habilito a opção de usar desconto manual
		IF (pr_perdctmx >  0 AND pr_fldctman = 0 OR
			  pr_perdctmx <= 0 AND pr_fldctman = 1)THEN 

			 vr_cdcritic := 0;
			 vr_dscritic := 'Desconto manual inválido! Favor verificar.';
			 pr_nmdcampo := 'perdctmx';
			 
			 RAISE vr_exc_erro;               
    END IF;
		
		-- Se não foi informado um percentual de desconto manual entre a faixa de valores e estiver habilitado a opção de usar desconto manual
		IF ((pr_perdctmx <= 0 OR pr_perdctmx > 100) AND
			   pr_fldctman = 1)THEN 

			 vr_cdcritic := 0;
			 vr_dscritic := 'Percentual Máximo de Desconto Manual deve ser informado. Utilizar 0,01% a 100,00%!';
			 pr_nmdcampo := 'perdctmx';
			 
			 RAISE vr_exc_erro;               
    END IF;
		
    --Valida Lote tarifa boleto impresso
    IF nvl(pr_nrlotblq,0) = 0 THEN
    
      vr_cdcritic := 58; 
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);  
      pr_nmdcampo := 'nrlotblq';
             
      RAISE vr_exc_erro;  
      
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

	PROCEDURE pc_valida_informacoes_web(pr_nrconven IN crapcco.nrconven%TYPE --Convenio
																		 ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco
																		 ,pr_nrdctabb IN crapcco.nrdctabb%TYPE --Conta base
																		 ,pr_cdbccxlt IN crapcco.cdbccxlt%TYPE --Caixa/lote
																		 ,pr_cdagenci IN crapcco.cdagenci%TYPE --Agencia
																		 ,pr_nrdolote IN crapcco.nrdolote%TYPE --Lote
																		 ,pr_cdhistor IN crapcco.cdhistor%TYPE --Histórico
																		 ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
																		 ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
																		 ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
																		 ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
																		 ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
																		 ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
																		 ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
																		 ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
																		 ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
																		 ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
																		 ,pr_dtmvtolt VARCHAR2                 --Data de movimento                       
																		 ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
																		 ,pr_flprotes IN crapcco.flprotes%TYPE --Usar opção protesto
																		 ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
																		 ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Permitir uso de float de
																		 ,pr_qtfltate IN crapcco.qtfltate%TYPE --Permitir uso de float até
																		 ,pr_qtdecini IN crapcco.qtdecini%TYPE --Usar descurso de prazo de
																		 ,pr_qtdecate IN crapcco.qtdecate%TYPE --Usar descurso de prazo até
																		 ,pr_fldctman IN crapcco.fldctman%TYPE --Permite desconto manual
																		 ,pr_perdctmx IN crapcco.perdctmx%TYPE --Percentual máximo de desconto manual
																		 ,pr_flgapvco IN crapcco.flgapvco%TYPE --Aprovação do coordenador
																		 ,pr_flrecipr IN crapcco.flrecipr%TYPE --Usar reciprocidade
																		 ,pr_cddepart IN VARCHAR2              --Departamento
																	 	 ,pr_cddopcao IN VARCHAR2              --Opção da tela
																		 ,pr_nmdatela IN VARCHAR2              --Nome da tela                          
																		 ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
																		 ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
																		 ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
																		 ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
																		 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
																		 ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
		/*---------------------------------------------------------------------------------------------------------------
  
			Programa : pc_valida_informacoes_web
			Sistema  : Conta-Corrente - Cooperativa de Credito
			Sigla    : CRED
			Autor    : Lucas Reinert
			Data     : Abril/2016                           Ultima atualizacao:
	    
			Dados referentes ao programa:
	    
			Frequencia: -----
			Objetivo   : Realiza a validação das informações para cadastro/alteração do registro de convenio na web
	    
			Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
    
		--Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
		
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
    vr_nmresbcc crapban.nmresbcc%TYPE;
    vr_des_erro VARCHAR2(10);
		
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
																		 ,pr_nrlotblq => pr_nrlotblq --Lote bloqueto
																		 ,pr_nrvarcar => pr_nrvarcar --Variacação da carteira de cobrança
																		 ,pr_cdcartei => pr_cdcartei --Código da carteira
																		 ,pr_nrbloque => pr_nrbloque --Número bloqueto
																		 ,pr_dsorgarq => pr_dsorgarq --Origem do arquivo
																		 ,pr_tamannro => pr_tamannro --Tamanho nosso número
																		 ,pr_nmdireto => pr_nmdireto --Nome do diretório
																		 ,pr_nmarquiv => pr_nmarquiv --Nome do arquivo
																		 ,pr_flcopcob => pr_flcopcob --Informe se utiliza sistema CoopCob
																		 ,pr_flgativo => pr_flgativo --Ativo/inativo																		 
																		 ,pr_dtmvtolt => pr_dtmvtolt --Data de movimento
																		 ,pr_flgregis => pr_flgregis --Cobrança registrada
																		 ,pr_flprotes => pr_flprotes --Usar opção protesto
																		 ,pr_flserasa => pr_flserasa --Pode negativar no Serasa. (0=Nao, 1=Sim)
																		 ,pr_qtdfloat => pr_qtdfloat --Permitir uso de float de
																		 ,pr_qtfltate => pr_qtfltate --Permitir uso de float até
																		 ,pr_qtdecini => pr_qtdecini --Usar descurso de prazo de
																		 ,pr_qtdecate => pr_qtdecate --Usar descurso de prazo até
																		 ,pr_fldctman => pr_fldctman --Permite desconto manual
																		 ,pr_perdctmx => pr_perdctmx --Percentual máximo de desconto manual
																		 ,pr_flgapvco => pr_flgapvco --Aprovação do coordenador
																		 ,pr_flrecipr => pr_flrecipr --Usar reciprocidade                                     ,pr_dsdepart => pr_dsdepart --Departamento
																		 ,pr_cddepart => pr_cddepart --Departamento
																		 ,pr_cddopcao => pr_cddopcao --Opção da tela
																		 ,pr_nmdatela => pr_nmdatela --Nome da tela                        
																		 ,pr_nmdbanco => vr_nmresbcc --Nome do banco                                     
																		 ,pr_cdcritic => vr_cdcritic --Cõdigo da critica
																		 ,pr_dscritic => vr_dscritic --Descrção da critica
																		 ,pr_nmdcampo => pr_nmdcampo --Nome do campo de retorno
																		 ,pr_des_erro => vr_des_erro); --Retorno OK;NOK
                                     
    IF vr_des_erro <> 'OK'      OR 
       nvl(vr_cdcritic,0) <> 0  OR 
       vr_dscritic IS NOT NULL  THEN      
       
      RAISE vr_exc_erro;
    
    END IF;

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
   																		
  END pc_valida_informacoes_web;                                     																		
  
  PROCEDURE pc_consulta (pr_nrconven IN crapcco.nrconven%TYPE --Convenio
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
    Data     : Marco/2016                         Ultima atualizacao: 12/09/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca cadastro de parametro de cobranca.
    
    Alterações : 12/09/2017 - Busca da Agencia do Banco do Brasil. (Jaison/Elton - M459)
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
          ,crapcco.dsorgarq
          ,crapcco.nmdireto
          ,crapcco.flcopcob
          ,crapcco.cdcartei
          ,crapcco.cdagenci
          ,crapcco.dtmvtolt
          ,crapcco.nrdolote
          ,crapcco.nrlotblq
          ,crapcco.nrvarcar
          ,crapcco.nrbloque
          ,crapcco.tamannro
          ,crapcco.nmarquiv
          ,crapcco.flgativo
          ,crapcco.flgregis
					,crapcco.flprotes
					,crapcco.qtdfloat
					,crapcco.flserasa
					,crapcco.qtfltate
					,crapcco.qtdecini
					,crapcco.qtdecate
					,crapcco.fldctman
					,crapcco.perdctmx
					,crapcco.flgapvco
					,crapcco.flrecipr
					,crapcco.idprmrec
					,crapcco.cdagedbb
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
                                                 '  <dsorgarq>' || rw_crapcco.dsorgarq||'</dsorgarq>'||
                                                 '  <nmdireto>' || rw_crapcco.nmdireto||'</nmdireto>'||
                                                 '  <dtmvtolt>' || to_char(rw_crapcco.dtmvtolt,'dd/mm/rrrr')||'</dtmvtolt>'||
                                                 '  <flcopcob>' || rw_crapcco.flcopcob||'</flcopcob>'||
                                                 '  <cdcartei>' || rw_crapcco.cdcartei||'</cdcartei>'||
                                                 '  <nmextbcc>' || rw_crapcco.nmdbanco||'</nmextbcc>'||                                                 
                                                 '  <cdagenci>' || rw_crapcco.cdagenci||'</cdagenci>'||
                                                 '  <nrdolote>' || gene0002.fn_mask(to_char(rw_crapcco.nrdolote),'zzz.zz9')||'</nrdolote>'||
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
 																								 '  <flprotes>' || rw_crapcco.flprotes||'</flprotes>' ||
																								 '  <qtfltate>' || rw_crapcco.qtfltate||'</qtfltate>' ||
																								 '  <qtdecini>' || rw_crapcco.qtdecini||'</qtdecini>' ||
																								 '  <qtdecate>' || rw_crapcco.qtdecate||'</qtdecate>' ||
																								 '  <fldctman>' || rw_crapcco.fldctman||'</fldctman>' ||
																								 '  <perdctmx>' || rw_crapcco.perdctmx||'</perdctmx>' ||
																								 '  <flgapvco>' || rw_crapcco.flgapvco||'</flgapvco>' ||
																								 '  <flrecipr>' || rw_crapcco.flrecipr||'</flrecipr>' ||
																								 '  <idprmrec>' || rw_crapcco.idprmrec||'</idprmrec>' ||
																								 '  <cdagedbb>' || LTrim(RTRIM(gene0002.fn_mask(rw_crapcco.cdagedbb, 'zzzzzz-9')))||'</cdagedbb>' ||
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
                        ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                        ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                        ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                        ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                        ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                        ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                        ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                        ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                        ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                        ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                        ,pr_dtmvtolt IN VARCHAR2              --Data de movimento
                        ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
												,pr_flprotes IN crapcco.flprotes%TYPE --Usar opção protesto
                        ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
                        ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Permitir uso de float de
                        ,pr_qtfltate IN crapcco.qtfltate%TYPE --Permitir uso de float até
                        ,pr_qtdecini IN crapcco.qtdecini%TYPE --Usar descurso de prazo de
                        ,pr_qtdecate IN crapcco.qtdecate%TYPE --Usar descurso de prazo até
                        ,pr_fldctman IN crapcco.fldctman%TYPE --Permite desconto manual
                        ,pr_perdctmx IN crapcco.perdctmx%TYPE --Percentual máximo de desconto manual
                        ,pr_flgapvco IN crapcco.flgapvco%TYPE --Aprovação do coordenador
                        ,pr_flrecipr IN crapcco.flrecipr%TYPE --Usar reciprocidade
                        ,pr_idprmrec IN crapcco.idprmrec%TYPE --Id da parametrização da reciprocidade cirada na CONFRP
                        ,pr_cdagedbb IN crapcco.cdagedbb%TYPE --Codigo da agencia no Banco do Brasil
                        ,pr_dslogcfg IN VARCHAR2              --Log das operações na tela CONFRP
                        ,pr_cddepart IN VARCHAR2              --Departamento
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
    Data     : Marco/2016                           Ultima atualizacao: 12/09/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Altera cadastro de parametro de cobranca.
    
    Alterações : 04/11/2016 - Adicionado tratamento para remover aspas duplas da mensagem 
                              de erro, para que seja exibido o erro correto no Ayllos WEB
                              (Douglas - Chamado 550711)

                 12/09/2017 - Alteracao da Agencia do Banco do Brasil. (Jaison/Elton - M459)
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
          ,cco.nrlotblq
          ,cco.nrvarcar
          ,cco.cdcartei
          ,cco.nrbloque
          ,cco.tamannro
          ,cco.nmdireto
          ,cco.nmarquiv
          ,cco.flcopcob
          ,cco.flgativo
          ,cco.dtmvtolt
          ,cco.cdoperad
          ,cco.flgregis
          ,cco.dsorgarq
          ,cco.flginter
					,cco.flprotes
					,cco.flserasa
					,cco.qtdfloat
					,cco.qtfltate
					,cco.qtdecini
					,cco.qtdecate
					,cco.fldctman
					,cco.perdctmx
					,cco.flgapvco
					,cco.flrecipr
					,cco.idprmrec
          ,cco.cdagedbb
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
                                     ,pr_nrlotblq => pr_nrlotblq --Lote bloqueto
                                     ,pr_nrvarcar => pr_nrvarcar --Variacação da carteira de cobrança
                                     ,pr_cdcartei => pr_cdcartei --Código da carteira
                                     ,pr_nrbloque => pr_nrbloque --Número bloqueto
                                     ,pr_dsorgarq => pr_dsorgarq --Origem do arquivo
                                     ,pr_tamannro => pr_tamannro --Tamanho nosso número
                                     ,pr_nmdireto => pr_nmdireto --Nome do diretório
                                     ,pr_nmarquiv => pr_nmarquiv --Nome do arquivo
                                     ,pr_flcopcob => pr_flcopcob --Informe se utiliza sistema CoopCob
                                     ,pr_flgativo => pr_flgativo --Ativo/inativo																		 
                                     ,pr_dtmvtolt => pr_dtmvtolt --Data de movimento
                                     ,pr_flgregis => pr_flgregis --Cobrança registrada
									                   ,pr_flprotes => pr_flprotes --Usar opção protesto
                                     ,pr_flserasa => pr_flserasa --Pode negativar no Serasa. (0=Nao, 1=Sim)
                                     ,pr_qtdfloat => pr_qtdfloat --Permitir uso de float de
                                     ,pr_qtfltate => pr_qtfltate --Permitir uso de float até
                                     ,pr_qtdecini => pr_qtdecini --Usar descurso de prazo de
                                     ,pr_qtdecate => pr_qtdecate --Usar descurso de prazo até
                                     ,pr_fldctman => pr_fldctman --Permite desconto manual
                                     ,pr_perdctmx => pr_perdctmx --Percentual máximo de desconto manual
                                     ,pr_flgapvco => pr_flgapvco --Aprovação do coordenador
                                     ,pr_flrecipr => pr_flrecipr --Usar reciprocidade   
																		 ,pr_cddepart => pr_cddepart --Departamento
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
                        ,crapcco.nrlotblq = pr_nrlotblq
                        ,crapcco.nrvarcar = pr_nrvarcar
                        ,crapcco.cdcartei = pr_cdcartei
                        ,crapcco.nrbloque = pr_nrbloque
                        ,crapcco.dsorgarq = pr_dsorgarq
                        ,crapcco.tamannro = pr_tamannro
                        ,crapcco.nmdireto = nvl(trim(pr_nmdireto),' ')
                        ,crapcco.nmarquiv = nvl(trim(pr_nmarquiv),' ')
                        ,crapcco.flcopcob = pr_flcopcob
                        ,crapcco.flgativo = pr_flgativo
                        ,crapcco.dtmvtolt = to_date(pr_dtmvtolt,'DD/MM/RRRR')
                        ,crapcco.cdoperad = vr_cdoperad
                        ,crapcco.flgregis = pr_flgregis
                        ,crapcco.flginter = decode(pr_dsorgarq,'INTERNET',1,'PROTESTO',1,'IMPRESSO PELO SOFTWARE',1,0)                                        
												,crapcco.flprotes = pr_flprotes
												,crapcco.flserasa = pr_flserasa
												,crapcco.qtdfloat = pr_qtdfloat
												,crapcco.qtfltate = pr_qtfltate
												,crapcco.qtdecini = pr_qtdecini
												,crapcco.qtdecate = pr_qtdecate
												,crapcco.fldctman = pr_fldctman
												,crapcco.perdctmx = pr_perdctmx
												,crapcco.flgapvco = pr_flgapvco
												,crapcco.flrecipr = pr_flrecipr
												,crapcco.idprmrec = pr_idprmrec
                        ,crapcco.cdagedbb = pr_cdagedbb
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
                       ,crapcco.nrlotblq
                       ,nvl(crapcco.nrvarcar,0)
                       ,nvl(crapcco.cdcartei,0)
                       ,crapcco.nrbloque
                       ,crapcco.dsorgarq
                       ,crapcco.tamannro
                       ,nvl(trim(crapcco.nmdireto),' ')
                       ,nvl(trim(crapcco.nmarquiv),' ')
                       ,crapcco.flcopcob
                       ,crapcco.flgativo
                       ,crapcco.dtmvtolt
                       ,crapcco.cdoperad
                       ,crapcco.flgregis
                       ,crapcco.flginter
											 ,crapcco.flprotes
                       ,crapcco.flserasa
                       ,crapcco.qtdfloat
                       ,crapcco.qtfltate
                       ,crapcco.qtdecini
                       ,crapcco.qtdecate
                       ,crapcco.fldctman
                       ,crapcco.perdctmx
                       ,crapcco.flgapvco
                       ,crapcco.flrecipr
											 ,crapcco.idprmrec
                       ,crapcco.cdagedbb
                  INTO rw_crapcco_new.cdcooper
                      ,rw_crapcco_new.nrconven
                      ,rw_crapcco_new.cddbanco
                      ,rw_crapcco_new.nmdbanco
                      ,rw_crapcco_new.nrdctabb
                      ,rw_crapcco_new.cdbccxlt
                      ,rw_crapcco_new.cdagenci
                      ,rw_crapcco_new.nrdolote
                      ,rw_crapcco_new.cdhistor
                      ,rw_crapcco_new.nrlotblq
                      ,rw_crapcco_new.nrvarcar
                      ,rw_crapcco_new.cdcartei
                      ,rw_crapcco_new.nrbloque
                      ,rw_crapcco_new.dsorgarq
                      ,rw_crapcco_new.tamannro
                      ,rw_crapcco_new.nmdireto
                      ,rw_crapcco_new.nmarquiv
                      ,rw_crapcco_new.flcopcob
                      ,rw_crapcco_new.flgativo
                      ,rw_crapcco_new.dtmvtolt
                      ,rw_crapcco_new.cdoperad
                      ,rw_crapcco_new.flgregis
                      ,rw_crapcco_new.flginter
											,rw_crapcco_new.flprotes
                      ,rw_crapcco_new.flserasa
                      ,rw_crapcco_new.qtdfloat
                      ,rw_crapcco_new.qtfltate
                      ,rw_crapcco_new.qtdecini
                      ,rw_crapcco_new.qtdecate
                      ,rw_crapcco_new.fldctman
                      ,rw_crapcco_new.perdctmx
                      ,rw_crapcco_new.flgapvco
                      ,rw_crapcco_new.flrecipr
                      ,rw_crapcco_new.idprmrec
                      ,rw_crapcco_new.cdagedbb;
                      
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
    
    /* Geração de LOG */
    pc_gera_log (pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 7
                ,pr_nrconven => pr_nrconven
                ,pr_dsdcampo => ''
                ,pr_vlrcampo => ''
                ,pr_vlcampo2 => '');  
                        
    IF rw_crapcco.cddbanco <> rw_crapcco_new.cddbanco THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Banco'
                   ,pr_vlrcampo => rw_crapcco.cddbanco
                   ,pr_vlcampo2 => rw_crapcco_new.cddbanco);
    END IF;
    
    IF rw_crapcco.nmdbanco <> rw_crapcco_new.nmdbanco THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Nome do banco'
                   ,pr_vlrcampo => rw_crapcco.nmdbanco
                   ,pr_vlcampo2 => rw_crapcco_new.nmdbanco);
    END IF;
    
    IF rw_crapcco.nrdctabb <> rw_crapcco_new.nrdctabb   THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Conta base'
                   ,pr_vlrcampo => rw_crapcco.nrdctabb
                   ,pr_vlcampo2 => rw_crapcco_new.nrdctabb);
    END IF;
    
    IF rw_crapcco.flgregis <> rw_crapcco_new.flgregis   THEN
        pc_gera_log(pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Cobranca Registrada'
                   ,pr_vlrcampo => rw_crapcco.flgregis
                   ,pr_vlcampo2 => rw_crapcco_new.flgregis);
    END IF;
    
    IF rw_crapcco.cdagedbb <> rw_crapcco_new.cdagedbb   THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Agencia BB'
                   ,pr_vlrcampo => rw_crapcco.cdagedbb
                   ,pr_vlcampo2 => rw_crapcco_new.cdagedbb);
    END IF;
    
    IF rw_crapcco.cdbccxlt <> rw_crapcco_new.cdbccxlt THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Banco/Caixa'
                   ,pr_vlrcampo => rw_crapcco.cdbccxlt
                   ,pr_vlcampo2 => rw_crapcco_new.cdbccxlt);
    END IF;
    
    IF rw_crapcco.cdagenci <> rw_crapcco_new.cdagenci THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'PA'
                   ,pr_vlrcampo => rw_crapcco.cdagenci
                   ,pr_vlcampo2 => rw_crapcco_new.cdagenci);
    END IF;
    
    IF rw_crapcco.nrdolote <> rw_crapcco_new.nrdolote THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Lote'
                   ,pr_vlrcampo => rw_crapcco.nrdolote
                   ,pr_vlcampo2 => rw_crapcco_new.nrdolote);
    END IF;
    
    IF rw_crapcco.cdhistor <> rw_crapcco_new.cdhistor THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Hist. tarifa especial'
                   ,pr_vlrcampo => rw_crapcco.cdhistor
                   ,pr_vlcampo2 => rw_crapcco_new.cdhistor);
    END IF;                                                                     
                 
    IF rw_crapcco.nrlotblq <> rw_crapcco_new.nrlotblq THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Lote impresso bloq.'
                   ,pr_vlrcampo => rw_crapcco.nrlotblq
                   ,pr_vlcampo2 => rw_crapcco_new.nrlotblq);
    END IF;       
       
    IF rw_crapcco.nrvarcar <> rw_crapcco_new.nrvarcar THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Var. carteira'
                   ,pr_vlrcampo => rw_crapcco.nrvarcar
                   ,pr_vlcampo2 => rw_crapcco_new.nrvarcar);
    END IF;
    
    IF rw_crapcco.cdcartei <> rw_crapcco_new.cdcartei THEN
        pc_gera_log (pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 2                   
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Cod. carteira'
                    ,pr_vlrcampo => rw_crapcco.cdcartei
                    ,pr_vlcampo2 => rw_crapcco_new.cdcartei);
    END IF;
                 
    IF rw_crapcco.nrbloque <> rw_crapcco_new.nrbloque THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Nro bloqueto'
                   ,pr_vlrcampo => rw_crapcco.nrbloque
                   ,pr_vlcampo2 => rw_crapcco_new.nrbloque);
    END IF;
       
    IF rw_crapcco.tamannro <> rw_crapcco_new.tamannro THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Tamanho do nro'
                   ,pr_vlrcampo => rw_crapcco.tamannro
                   ,pr_vlcampo2 => rw_crapcco_new.tamannro);
    END IF;
       
    IF nvl(trim(rw_crapcco.nmdireto),' ') <> rw_crapcco_new.nmdireto THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Diretorio'
                   ,pr_vlrcampo => nvl(trim(rw_crapcco.nmdireto),' ')
                   ,pr_vlcampo2 => rw_crapcco_new.nmdireto);
    END IF;
    
    IF nvl(trim(rw_crapcco.nmarquiv),' ') <> rw_crapcco_new.nmarquiv THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Arquivo'
                   ,pr_vlrcampo => rw_crapcco.nmarquiv
                   ,pr_vlcampo2 => rw_crapcco_new.nmarquiv);
    END IF;                                                  
                                                                                                      
    IF rw_crapcco.flcopcob <> rw_crapcco_new.flcopcob THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Utiliza CoopCob'
                   ,pr_vlrcampo => (CASE rw_crapcco.flcopcob WHEN 1 THEN 'SIM' ELSE 'NAO' END)
                   ,pr_vlcampo2 => (CASE rw_crapcco_new.flcopcob WHEN 1 THEN 'SIM' ELSE 'NAO' END));
    END IF;
         
    IF rw_crapcco.flgativo <> rw_crapcco_new.flgativo THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Ativo'
                   ,pr_vlrcampo => (CASE rw_crapcco.flgativo WHEN 1 THEN 'ATIVO' ELSE 'INATIVO' END)
                   ,pr_vlcampo2 => (CASE rw_crapcco_new.flgativo WHEN 1 THEN 'ATIVO' ELSE 'INATIVO' END) );
       
    END IF;
    
    IF rw_crapcco.dtmvtolt <> rw_crapcco_new.dtmvtolt THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Data ult. alteracao'
                   ,pr_vlrcampo => rw_crapcco.dtmvtolt
                   ,pr_vlcampo2 => rw_crapcco_new.dtmvtolt);
    END IF;
         
    IF rw_crapcco.cdoperad <> rw_crapcco_new.cdoperad THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Operador'
                   ,pr_vlrcampo => rw_crapcco.cdoperad
                   ,pr_vlcampo2 => rw_crapcco_new.cdoperad);
    
    END IF;
      
    IF rw_crapcco.dsorgarq  <> rw_crapcco_new.dsorgarq THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Origem arquivo'
                   ,pr_vlrcampo => rw_crapcco.dsorgarq
                   ,pr_vlcampo2 => rw_crapcco_new.dsorgarq);
    END IF;
         
    IF rw_crapcco.flginter <> rw_crapcco_new.flginter   THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Convenio internet'
                   ,pr_vlrcampo => rw_crapcco.flginter
                   ,pr_vlcampo2 => rw_crapcco_new.flginter);
    END IF;    
		
    IF rw_crapcco.flprotes <> rw_crapcco_new.flprotes THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Utiliza protesto'
                   ,pr_vlrcampo => (CASE rw_crapcco.flprotes WHEN 1 THEN 'SIM' ELSE 'NAO' END)
                   ,pr_vlcampo2 => (CASE rw_crapcco_new.flprotes WHEN 1 THEN 'SIM' ELSE 'NAO' END));
    END IF;
		
    IF rw_crapcco.qtdfloat <> rw_crapcco_new.qtdfloat THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Float De'
                   ,pr_vlrcampo => rw_crapcco.qtdfloat
                   ,pr_vlcampo2 => rw_crapcco_new.qtdfloat);
    END IF;

    IF rw_crapcco.qtfltate <> rw_crapcco_new.qtfltate THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Float Ate'
                   ,pr_vlrcampo => rw_crapcco.qtfltate
                   ,pr_vlcampo2 => rw_crapcco_new.qtfltate);
    END IF;

    IF rw_crapcco.qtdecini <> rw_crapcco_new.qtdecini THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Descurso de prazo de'
                   ,pr_vlrcampo => rw_crapcco.qtdecini
                   ,pr_vlcampo2 => rw_crapcco_new.qtdecini);
    END IF;

    IF rw_crapcco.qtdecate <> rw_crapcco_new.qtdecate THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Descurso de prazo ate'
                   ,pr_vlrcampo => rw_crapcco.qtdecate
                   ,pr_vlcampo2 => rw_crapcco_new.qtdecate);
    END IF;

    IF rw_crapcco.fldctman <> rw_crapcco_new.fldctman THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Permite desconto manual'
                   ,pr_vlrcampo => (CASE rw_crapcco.fldctman WHEN 1 THEN 'SIM' ELSE 'NAO' END)
                   ,pr_vlcampo2 => (CASE rw_crapcco_new.fldctman WHEN 1 THEN 'SIM' ELSE 'NAO' END));
    END IF;

    IF rw_crapcco.perdctmx <> rw_crapcco_new.perdctmx THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => '% Maximo desconto manual'
                   ,pr_vlrcampo => (to_char(rw_crapcco.perdctmx, 'fm990d00') || '%')
                   ,pr_vlcampo2 => (to_char(rw_crapcco_new.perdctmx, 'fm990d00') || '%'));
    END IF;

    IF rw_crapcco.flgapvco <> rw_crapcco_new.flgapvco THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Aprovacao coordenador'
                   ,pr_vlrcampo => (CASE rw_crapcco.flgapvco WHEN 1 THEN 'SIM' ELSE 'NAO' END)
                   ,pr_vlcampo2 => (CASE rw_crapcco_new.flgapvco WHEN 1 THEN 'SIM' ELSE 'NAO' END));
    END IF;

    IF rw_crapcco.flrecipr <> rw_crapcco_new.flrecipr THEN
       pc_gera_log (pr_cdoperad => vr_cdoperad
                   ,pr_tipdolog => 2                   
                   ,pr_nrconven => pr_nrconven
                   ,pr_dsdcampo => 'Reciprocidade'
                   ,pr_vlrcampo => (CASE rw_crapcco.flrecipr WHEN 1 THEN 'SIM' ELSE 'NAO' END)
                   ,pr_vlcampo2 => (CASE rw_crapcco_new.flrecipr WHEN 1 THEN 'SIM' ELSE 'NAO' END));
    END IF;
				
    /* Incrementar o LOG da tela dependente CONFRP (se rerebido) 
       Observações: trocamos os caracteres conforme lista abaixo devido problemas entre XML>PHP>Oracle
                  - [fl] para -->
                  - [br] para chr(10)
       */    
    IF trim(pr_dslogcfg) IS NOT NULL THEN
      vr_dslogtel := vr_dslogtel || replace(replace(pr_dslogcfg,'[fl]','-->'),'[br]',chr(10));
    END IF;
    
    -- Envio envia ao log as informações em memória
    pc_gera_log_arquivo(vr_cdcooper,vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
    pr_des_erro := 'OK';
    
    COMMIT;    
    
  EXCEPTION
    WHEN vr_exc_erro THEN 
                   
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic:= replace(replace(vr_dscritic,'"',''),'''','');
      pr_nmdcampo := vr_nmdcampo;
              
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                     
      ROLLBACK;
                                                                                                   
    WHEN OTHERS THEN 
      
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= replace(replace('Erro na pc_alteracao --> '|| SQLERRM,'"',''),'''','');
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
      
      ROLLBACK;
      
  END pc_alteracao;   
  
  PROCEDURE pc_exclusao (pr_nrconven  IN crapcco.nrconven%TYPE --Convenio
                        ,pr_dtmvtolt  IN VARCHAR2              --Data de movimento 
                        ,pr_cddopcao  IN VARCHAR               --Opção da tela
                        ,pr_cddepart  IN VARCHAR               --Departamento
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
    Data     : Marco/2016                           Ultima atualizacao: 04/11/2016
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Exclui cadastro de parametro de cobranca.
    
    Alterações : 04/11/2016 - Adicionado tratamento para remover aspas duplas da mensagem 
                              de erro, para que seja exibido o erro correto no Ayllos WEB
                              (Douglas - Chamado 550711)
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
    
    IF pr_cddepart NOT IN (1,18,20) THEN 
       
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
    
    pc_gera_log (pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 3
                ,pr_nrconven => pr_nrconven
                ,pr_dsdcampo => ''
                ,pr_vlrcampo => ''
                ,pr_vlcampo2 => ''); 

    -- Envio envia ao log as informações em memória
    pc_gera_log_arquivo(vr_cdcooper,vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
    pr_des_erro := 'OK';
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN 
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= replace(replace(vr_dscritic,'"',''),'''','');

        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');  
                                     
      ROLLBACK;
                                                                                                     
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= replace(replace('Erro na pc_exclusao --> '|| SQLERRM,'"',''),'''','');
        
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
                        ,pr_nrlotblq IN crapcco.nrlotblq%TYPE --Lote bloqueto
                        ,pr_nrvarcar IN crapcco.nrvarcar%TYPE --Variacação da carteira de cobrança
                        ,pr_cdcartei IN crapcco.cdcartei%TYPE --Código da carteira
                        ,pr_nrbloque IN crapcco.nrbloque%TYPE --Número bloqueto
                        ,pr_dsorgarq IN crapcco.dsorgarq%TYPE --Origem do arquivo
                        ,pr_tamannro IN crapcco.tamannro%TYPE --Tamanho nosso número
                        ,pr_nmdireto IN crapcco.nmdireto%TYPE --Nome do diretório
                        ,pr_nmarquiv IN crapcco.nmarquiv%TYPE --Nome do arquivo
                        ,pr_flcopcob IN crapcco.flcopcob%TYPE --Informe se utiliza sistema CoopCob
                        ,pr_flgativo IN crapcco.flgativo%TYPE --Ativo/inativo
                        ,pr_dtmvtolt VARCHAR2                 --Data de movimento                       
                        ,pr_flgregis IN crapcco.flgregis%TYPE --Cobrança registrada
												,pr_flprotes IN crapcco.flprotes%TYPE --Usar opção protesto
                        ,pr_flserasa IN crapcco.flserasa%TYPE --Pode negativar no Serasa. (0=Nao, 1=Sim)
                        ,pr_qtdfloat IN crapcco.qtdfloat%TYPE --Permitir uso de float de
                        ,pr_qtfltate IN crapcco.qtfltate%TYPE --Permitir uso de float até
                        ,pr_qtdecini IN crapcco.qtdecini%TYPE --Usar descurso de prazo de
                        ,pr_qtdecate IN crapcco.qtdecate%TYPE --Usar descurso de prazo até
                        ,pr_fldctman IN crapcco.fldctman%TYPE --Permite desconto manual
                        ,pr_perdctmx IN crapcco.perdctmx%TYPE --Percentual máximo de desconto manual
                        ,pr_flgapvco IN crapcco.flgapvco%TYPE --Aprovação do coordenador
                        ,pr_flrecipr IN crapcco.flrecipr%TYPE --Usar reciprocidade
                        ,pr_idprmrec IN crapcco.idprmrec%TYPE --Id da parametrização da reciprocidade cirada na CONFRP
                        ,pr_cdagedbb IN crapcco.cdagedbb%TYPE --Codigo da agencia no Banco do Brasil
                        ,pr_dslogcfg IN VARCHAR2              --Log das operações na tela CONFRP
                        ,pr_cddepart IN VARCHAR2              --Departamento
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
    Data     : Marco/2016                           Ultima atualizacao: 12/09/2017
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Inclui cadastro de parametro de cobranca.
    
    Alterações : 04/11/2016 - Adicionado tratamento para remover aspas duplas da mensagem 
                              de erro, para que seja exibido o erro correto no Ayllos WEB
                              (Douglas - Chamado 550711)

                 12/09/2017 - Inclusao da Agencia do Banco do Brasil. (Jaison/Elton - M459)
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
                                     ,pr_nrlotblq => pr_nrlotblq --Lote bloqueto
                                     ,pr_nrvarcar => pr_nrvarcar --Variacação da carteira de cobrança
                                     ,pr_cdcartei => pr_cdcartei --Código da carteira
                                     ,pr_nrbloque => pr_nrbloque --Número bloqueto
                                     ,pr_dsorgarq => pr_dsorgarq --Origem do arquivo
                                     ,pr_tamannro => pr_tamannro --Tamanho nosso número
                                     ,pr_nmdireto => pr_nmdireto --Nome do diretório
                                     ,pr_nmarquiv => pr_nmarquiv --Nome do arquivo
                                     ,pr_flcopcob => pr_flcopcob --Informe se utiliza sistema CoopCob
                                     ,pr_flgativo => pr_flgativo --Ativo/inativo
                                     ,pr_dtmvtolt => pr_dtmvtolt --Data de movimento
                                     ,pr_flgregis => pr_flgregis --Cobrança registrada
 									                   ,pr_flprotes => pr_flprotes --Usar opção protesto
                                     ,pr_flserasa => pr_flserasa --Pode negativar no Serasa. (0=Nao, 1=Sim)
                                     ,pr_qtdfloat => pr_qtdfloat --Permitir uso de float de
                                     ,pr_qtfltate => pr_qtfltate --Permitir uso de float até
                                     ,pr_qtdecini => pr_qtdecini --Usar descurso de prazo de
                                     ,pr_qtdecate => pr_qtdecate --Usar descurso de prazo até
                                     ,pr_fldctman => pr_fldctman --Permite desconto manual
                                     ,pr_perdctmx => pr_perdctmx --Percentual máximo de desconto manual
                                     ,pr_flgapvco => pr_flgapvco --Aprovação do coordenador
                                     ,pr_flrecipr => pr_flrecipr --Usar reciprocidade                                     ,pr_dsdepart => pr_dsdepart --Departamento
                                     ,pr_cddepart => pr_cddepart --Departamento
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
                         ,crapcco.nrlotblq
                         ,crapcco.nrvarcar
                         ,crapcco.cdcartei
                         ,crapcco.nrbloque
                         ,crapcco.dsorgarq
                         ,crapcco.tamannro
                         ,crapcco.nmdireto
                         ,crapcco.nmarquiv
                         ,crapcco.flcopcob
                         ,crapcco.flgativo
                         ,crapcco.dtmvtolt
                         ,crapcco.cdoperad
                         ,crapcco.cdcooper
                         ,crapcco.flgregis
                         ,crapcco.flginter
	 											 ,crapcco.flprotes
												 ,crapcco.flserasa
												 ,crapcco.qtdfloat
												 ,crapcco.qtfltate
												 ,crapcco.qtdecini
												 ,crapcco.qtdecate
												 ,crapcco.fldctman
												 ,crapcco.perdctmx
												 ,crapcco.flgapvco
												 ,crapcco.flrecipr
												 ,crapcco.idprmrec
                         ,crapcco.cdagedbb)
                  VALUES(pr_nrconven
                        ,pr_cddbanco
                        ,vr_nmresbcc
                        ,pr_nrdctabb
                        ,pr_cdbccxlt
                        ,pr_cdagenci
                        ,pr_nrdolote
                        ,pr_cdhistor
                        ,pr_nrlotblq
                        ,nvl(pr_nrvarcar,0)
                        ,nvl(pr_cdcartei,0)
                        ,pr_nrbloque
                        ,pr_dsorgarq
                        ,pr_tamannro
                        ,pr_nmdireto
                        ,pr_nmarquiv
                        ,pr_flcopcob
                        ,pr_flgativo
                        ,to_date(pr_dtmvtolt,'DD/MM/RRRR')
                        ,vr_cdoperad
                        ,vr_cdcooper
                        ,pr_flgregis
                        ,decode(pr_dsorgarq,'INTERNET',1,'PROTESTO',1,'IMPRESSO PELO SOFTWARE',1,0) 
												,pr_flprotes
                        ,pr_flserasa
                        ,pr_qtdfloat
                        ,pr_qtfltate
                        ,pr_qtdecini
                        ,pr_qtdecate
                        ,pr_fldctman
                        ,pr_perdctmx
                        ,pr_flgapvco
                        ,pr_flrecipr
                        ,NVL(TRIM(pr_idprmrec),0)
                        ,pr_cdagedbb);
                          
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
    
    /* Geração de LOG */                 
    pc_gera_log (pr_cdoperad => vr_cdoperad
                ,pr_tipdolog => 1
                ,pr_nrconven => pr_nrconven
                ,pr_dsdcampo => ''
                ,pr_vlrcampo => ''
                ,pr_vlcampo2 => '');  
                
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Banco'
               ,pr_vlrcampo => pr_cddbanco
               ,pr_vlcampo2 => '');
    
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Conta base'
               ,pr_vlrcampo => pr_nrdctabb
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
              ,pr_tipdolog => 6                   
              ,pr_nrconven => pr_nrconven
              ,pr_dsdcampo => 'Cobranca Registrada'
              ,pr_vlrcampo => pr_flgregis
              ,pr_vlcampo2 => '');
    
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Agencia BB'
               ,pr_vlrcampo => pr_cdagedbb
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Banco/Caixa'
               ,pr_vlrcampo => pr_cdbccxlt
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'PA'
               ,pr_vlrcampo => pr_cdagenci
               ,pr_vlcampo2 => '');
 
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Lote'
               ,pr_vlrcampo => pr_nrdolote
               ,pr_vlcampo2 => '');
 
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Hist. tarifa especial'
               ,pr_vlrcampo => pr_cdhistor
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Lote impresso bloq.'
               ,pr_vlrcampo => pr_nrlotblq
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Var. carteira'
               ,pr_vlrcampo => pr_nrvarcar
               ,pr_vlcampo2 => '');
 
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Cod. carteira'
               ,pr_vlrcampo => pr_cdcartei
               ,pr_vlcampo2 => '');
 
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Nro bloqueto'
               ,pr_vlrcampo => pr_nrbloque
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Tamanho do nro'
               ,pr_vlrcampo => pr_tamannro
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Diretorio'
               ,pr_vlrcampo => nvl(trim(pr_nmdireto),' ')
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Arquivo'
               ,pr_vlrcampo => pr_nmarquiv
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Utiliza CoopCob'
               ,pr_vlrcampo =>(CASE pr_flcopcob WHEN 1 THEN 'SIM' ELSE 'NAO' END)
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Ativo'
               ,pr_vlrcampo =>(CASE pr_flgativo WHEN 1 THEN 'ATIVO' ELSE 'INATIVO' END)
               ,pr_vlcampo2 => '' );
    
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Data ult. alteracao'
               ,pr_vlrcampo => pr_dtmvtolt
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Operador'
               ,pr_vlrcampo => vr_cdoperad
               ,pr_vlcampo2 => '');
 
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Origem arquivo'
               ,pr_vlrcampo => pr_dsorgarq
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Convenio internet'
               ,pr_vlrcampo => (CASE pr_dsorgarq WHEN 'INTERNET' THEN 1 WHEN 'PROTESTO' THEN 1 WHEN 'IMPRESSO PELO SOFTWARE' THEN 1 ELSE 0 END)
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Utiliza protesto'
               ,pr_vlrcampo =>(CASE pr_flprotes WHEN 1 THEN 'SIM' ELSE 'NAO' END)
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Float De'
               ,pr_vlrcampo => pr_qtdfloat
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Float Ate'
               ,pr_vlrcampo => pr_qtfltate
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Descurso de prazo de'
               ,pr_vlrcampo => pr_qtdecini
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Descurso de prazo ate'
               ,pr_vlrcampo => pr_qtdecate
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Permite desconto manual'
               ,pr_vlrcampo =>(CASE pr_fldctman WHEN 1 THEN 'SIM' ELSE 'NAO' END)
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => '% Maximo desconto manual'
               ,pr_vlrcampo =>(to_char(pr_perdctmx, 'fm990d00') || '%')
               ,pr_vlcampo2 => '');
 
    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Aprovacao coordenador'
               ,pr_vlrcampo =>(CASE pr_flgapvco WHEN 1 THEN 'SIM' ELSE 'NAO' END)
               ,pr_vlcampo2 => '');

    pc_gera_log(pr_cdoperad => vr_cdoperad
               ,pr_tipdolog => 6                   
               ,pr_nrconven => pr_nrconven
               ,pr_dsdcampo => 'Reciprocidade'
               ,pr_vlrcampo =>(CASE pr_flrecipr WHEN 1 THEN 'SIM' ELSE 'NAO' END)
               ,pr_vlcampo2 => '');            
    
    /* Incrementar o LOG da tela dependente CONFRP (se rerebido) 
       Observações: trocamos os caracteres conforme lista abaixo devido problemas entre XML>PHP>Oracle
                  - [fl] para -->
                  - [br] para chr(10)
       */    
    IF trim(pr_dslogcfg) IS NOT NULL THEN
      vr_dslogtel := vr_dslogtel || replace(replace(pr_dslogcfg,'[fl]','-->'),'[br]',chr(10));
    END IF;
    
    -- Envio envia ao log as informações em memória
    pc_gera_log_arquivo(vr_cdcooper,vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    

    
    pr_des_erro := 'OK';
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN 
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= replace(replace(vr_dscritic,'"',''),'''','');
      pr_nmdcampo:= vr_nmdcampo;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');  
                                     
      ROLLBACK;
                                                                                                     
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= replace(replace('Erro na pc_inclusao --> '|| SQLERRM,'"',''),'''','');
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
      ROLLBACK;   
  
  END pc_inclusao;                      
 
  PROCEDURE pc_consulta_tarifas(pr_nrconven IN crapcco.nrconven%TYPE --Convenio
                               ,pr_dtmvtolt IN VARCHAR2              --Data de movimento
                               ,pr_cddbanco IN crapcco.cddbanco%TYPE --Banco                              
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
        pc_gera_log (pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 4
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Valor da tarifa'
                    ,pr_vlrcampo => TRIM(TO_CHAR(vr_tab_registros(vr_index).avltarifa, 'fm999g990d00'))
                    ,pr_vlcampo2 => TRIM(TO_CHAR(vr_tab_registros(vr_index).nvltarifa, 'fm999g990d00')));
                     
      END IF;
      
      IF vr_tab_registros(vr_index).acdtarhis <> vr_tab_registros(vr_index).ncdtarhis THEN
        pc_gera_log (pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 4
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Historico'
                    ,pr_vlrcampo => vr_tab_registros(vr_index).acdtarhis
                    ,pr_vlcampo2 => vr_tab_registros(vr_index).ncdtarhis);
                     
      END IF;  
      
      --Proximo Registro
      vr_index:= vr_tab_registros.NEXT(vr_index);
                   
    END LOOP;
    
    -- Acionar a gravação do log pendente em memória
    pc_gera_log_arquivo(vr_cdcooper,vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
              
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
        pc_gera_log (pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 5
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Valor da tarifa' 
                    ,pr_vlrcampo => TRIM(TO_CHAR(vr_tab_registros(vr_index).avltarifa, 'fm999g990d00')) 
                    ,pr_vlcampo2 => TRIM(TO_CHAR(vr_tab_registros(vr_index).nvltarifa, 'fm999g990d00')) );
                     
      END IF;
      
      IF vr_tab_registros(vr_index).acdtarhis <> vr_tab_registros(vr_index).ncdtarhis THEN
        pc_gera_log (pr_cdoperad => vr_cdoperad
                    ,pr_tipdolog => 5
                    ,pr_nrconven => pr_nrconven
                    ,pr_dsdcampo => 'Historico'
                    ,pr_vlrcampo => vr_tab_registros(vr_index).acdtarhis
                    ,pr_vlcampo2 => vr_tab_registros(vr_index).ncdtarhis);
                     
      END IF;  
      
      --Proximo Registro
      vr_index:= vr_tab_registros.NEXT(vr_index);
                   
    END LOOP;
    
    -- Acionar a gravação do log pendente em memória
    pc_gera_log_arquivo(vr_cdcooper,vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
    
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
