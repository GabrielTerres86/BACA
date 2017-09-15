CREATE OR REPLACE PACKAGE CECRED.TELA_IMPSIM AS

  --PROCEDURE pc_importar_arquivo_SIM(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
  --                                 ,
  --                                  pr_cdcritic OUT PLS_INTEGER --> Código da crítica
  --                                 ,
   --                                 pr_dscritic OUT VARCHAR2 --> Descrição da crítica
   --                                ,
   --                                 pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
   --                                ,
   --                                 pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
   --                                ,
   --                                 pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_exportar_arquivo_SIM(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

END TELA_IMPSIM;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_IMPSIM AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_IMPSIM
  --    Autor   : Diogo Carlassara
  --    Data    : 15/09/2017                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Importação e exportação de cadastros cooperados Simples Nacional
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
    
--  PROCEDURE pc_importar_arquivo_SIM(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
--                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
--                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
--                             ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
--                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
--                             ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
--    
--  BEGIN
--      
--  END pc_importar_arquivo_SIM;

  PROCEDURE pc_exportar_arquivo_SIM(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
                               
      vr_endarqui varchar2(100);
      vr_nm_arquivo varchar(2000);
      vr_nm_arqlog  varchar2(2000);
      vr_cdcooper integer;
      vr_cdcritic integer;
      
      vr_handle_arq utl_file.file_type;
      vr_handle_log utl_file.file_type;
		
      vr_linha_arq     varchar2(2000);
      vr_linha_arq_log varchar2(2000);
      vr_des_erro  varchar2(2000);
      vr_dscritic varchar2(2000);
      
      --Controle de erro
      vr_exc_erro       EXCEPTION;
    
  
    CURSOR cr_crapjur IS
        SELECT j.cdcooper, a.nrcpfcgc, j.nrdconta 
        FROM crapjur j
        INNER JOIN crapass a on a.cdcooper = j.cdcooper and a.nrdconta = j.nrdconta
        WHERE a.inpessoa >= 2
        ORDER BY j.cdcooper, a.nrcpfcgc, j.nrdconta;
    
    BEGIN
      
    vr_cdcooper := 3;    
    vr_endarqui:= gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => '/impsim/');
										  
    vr_nm_arquivo := vr_endarqui || '/exportacao-simples-nacional.csv';
	  vr_nm_arqlog  := vr_endarqui || '/exportacao_sn_log';
		
    /* Abrir o arquivo de LOG
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arqlog
                            ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_log --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro); */
                            
    /* Abrir o arquivo de exportação */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo
                            ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_arq --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro); 

    if vr_des_erro is not null then
       vr_des_erro := 'Rotina pc_exportar_arquivo_SIM: Erro abertura arquivo de exportacao!' || sqlerrm;
       pr_cdcritic := 6;
       raise vr_exc_erro;
    end if;
	
    FOR rw_crapjur IN cr_crapjur LOOP
      
        vr_linha_arq := rw_crapjur.cdcooper || ';' || rw_crapjur.nrcpfcgc || ';' || rw_crapjur.nrdconta;
        dbms_output.put_line('Linha: ' || vr_linha_arq);
        
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                       pr_des_text => vr_linha_arq);
        
    END LOOP; 
   
    COMMIT;
  
    -- Fecha arquivos
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
    --gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
          
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_IMPSIM.PC_EXPORTAR_ARQUIVO_SIM --> ' ||SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_exportar_arquivo_SIM;

END TELA_IMPSIM;
/
