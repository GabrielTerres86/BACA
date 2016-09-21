CREATE OR REPLACE PACKAGE CECRED.gene0009 AS

  /*---------------------------------------------------------------------------------------------------------------

      Programa : GENE0008
      Sistema  : Rotinas genéricas
      Sigla    : GENE
      Autor    : Odirlei Busana - AMcom
      Data     : Outubro/2015.                   Ultima atualizacao: 05/10/2015

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Definir variaveis e funções genericas

      Alterações:
  ------------------------------------------------------------------------------------------------------------------*/
  --------------> CURSORES <------------------
  -- Ler os campos dos layouts
  CURSOR cr_campo_layout (pr_idlayout tbgen_layout_campo.idlayout%TYPE) IS
    SELECT tpregistro
          ,nrsequencia_campo
          ,nmcampo
          ,tpdado
          ,dsformato
          ,nrposicao_inicial
          ,qtdposicoes
          ,power(10,qtddecimais) vldivisao --> definir valor de divisão conforme qtd de decimais
          ,dsidentificador_registro
      FROM tbgen_layout_campo campo_layout
     WHERE campo_layout.idlayout = pr_idlayout
     ORDER BY campo_layout.tpregistro
             ,campo_layout.nrsequencia_campo;
  rw_campo_layout cr_campo_layout%ROWTYPE;
  
  
  --> TempTable para retornar as linhas/campos do arquivo conforme o layout
  TYPE typ_rec_campos 
    IS RECORD (data DATE,
               texto VARCHAR2(4000),
               numero NUMBER);
  TYPE typ_tab_campos IS TABLE OF typ_rec_campos
    INDEX BY VARCHAR2(20); --dsdcampo              
                  
  TYPE typ_tab_linhas IS TABLE OF typ_tab_campos
    INDEX BY PLS_INTEGER;
  
  -- Temptable para armazenar os campos do layout 
  TYPE typ_tab_layout IS TABLE OF cr_campo_layout%ROWTYPE
    INDEX BY PLS_INTEGER;
    
  TYPE typ_tab_layouts IS TABLE OF typ_tab_layout
     INDEX BY VARCHAR2(5); --cdlayout  
  vr_tab_layouts typ_tab_layouts;
  
  -- Utilizada para armazenar os campos que sao utilizados como regra para identificar 
  -- o tipo de registro de cada linha
  vr_tab_regras  typ_tab_layouts;  
  
  PROCEDURE pc_importa_arq_layout ( pr_nmlayout   IN VARCHAR2,            --> Nome do Layout do arquivo a ser importado
                                    pr_dsdireto   IN VARCHAR2,            --> Descrição do diretorio onde o arquivo se enconta
                                    pr_nmarquiv   IN VARCHAR2,            --> Nome do arquivo a ser importado
                                    -----> OUT <------ 
                                    pr_dscritic   OUT VARCHAR2,           --> Retorna critica Caso ocorra
                                    pr_tab_linhas OUT typ_tab_linhas);    --> Retorna as linhas/campos do arquivo na temptable
  
END  gene0009;
/

CREATE OR REPLACE PACKAGE BODY CECRED.gene0009 AS

  /*---------------------------------------------------------------------------------------------------------------

      Programa : GENE0008
      Sistema  : Rotinas genéricas
      Sigla    : GENE
      Autor    : Odirlei Busana - AMcom
      Data     : Outubro/2015.                   Ultima atualizacao: 05/10/2015

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Definir variaveis e funções genericas

      Alterações:
  ------------------------------------------------------------------------------------------------------------------*/
  PROCEDURE pc_importa_arq_layout ( pr_nmlayout   IN VARCHAR2,            --> Nome do Layout do arquivo a ser importado
                                    pr_dsdireto   IN VARCHAR2,            --> Descrição do diretorio onde o arquivo se enconta
                                    pr_nmarquiv   IN VARCHAR2,            --> Nome do arquivo a ser importado
                                    -----> OUT <------ 
                                    pr_dscritic   OUT VARCHAR2,           --> Retorna critica Caso ocorra
                                    pr_tab_linhas OUT typ_tab_linhas) IS  --> Retorna as linhas/campos do arquivo na temptable
    /* ..........................................................................
    --
    --  Programa : pc_importa_arquivo
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Outubro/2015.                   Ultima atualizacao: 05/10/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para importar respeitando o layout cadastrado e retornar 
    --               temptable com as linhas do arquivo.
    --
    --  Alteração : 
    --
    --
    -- ..........................................................................*/
    
      ------------------> CURSORES <----------------
      CURSOR cr_layout IS
        SELECT layout.idlayout,
               layout.dsdelimitador
          FROM tbgen_layout layout
         WHERE layout.nmlayout = pr_nmlayout;
      rw_layout cr_layout%ROWTYPE;
      
      
      -----------------> VARIAVEIS <-----------------
      vr_ind_arquiv utl_file.file_type;
      vr_dslinha    VARCHAR2(4000);              
      vr_textarq    VARCHAR2(4000);
      vr_contlin    INTEGER := 0;
      vr_dscritic   VARCHAR2(500);
      vr_exc_erro   EXCEPTION;
      vr_tpregistro tbgen_layout_campo.tpregistro%TYPE;
      vr_tab_linhas typ_tab_linhas;
        vr_nmcampo   VARCHAR2(100);
        vr_dsformato tbgen_layout_campo.dsformato%TYPE;
        vr_split     gene0002.typ_split;
        
      
      -----------------> SUBPROGRAMAS <--------------
      --> Carregar layout que serao utilizados
      PROCEDURE pc_carrega_layouts(pr_idlayout IN tbgen_layout_campo.idlayout%TYPE) IS      
      BEGIN
        -- Ler os campos do layout e armazenar na temptable para ter melhor performace ao ler as linhas
        FOR rw_campo_layout IN cr_campo_layout(pr_idlayout => pr_idlayout) LOOP
          vr_tab_layouts(rw_campo_layout.tpregistro)(rw_campo_layout.nrsequencia_campo) := rw_campo_layout;
          
          IF TRIM(rw_campo_layout.dsidentificador_registro) IS NOT NULL THEN
            vr_tab_regras(rw_campo_layout.tpregistro)(rw_campo_layout.nrsequencia_campo) := rw_campo_layout;
          END IF;
          
        END LOOP;
        
      END pc_carrega_layouts;
      
      -- Funcao para identificar o tipo de registro que pertence a linha
      FUNCTION fn_retorna_tpregistro ( pr_dslinha  IN  VARCHAR2,
                                       pr_dscritic OUT VARCHAR2) 
                                       RETURN tbgen_layout_campo.tpregistro%TYPE IS
      
        vr_tpregistro    tbgen_layout_campo.tpregistro%TYPE;
        vr_idxreg        VARCHAR2(5);
        vr_dscampo_linha VARCHAR2(4000);
        vr_flgregra      BOOLEAN;
        
      BEGIN
      
        -- Caso possuir somente um ou nenhum tipo de registro deve retornar na tab_layout
        IF vr_tab_regras.count <= 1 THEN
          RETURN TRIM(vr_tab_layouts.first);
        END IF;
      
        -- varrer os campos que possuem a informação para identificar o tipo de registro 
        -- e comparar com a posicao no arquico
        vr_idxreg := vr_tab_regras.first;
        WHILE vr_idxreg IS NOT NULL LOOP
          -- verificar campos do tipo de registro
          FOR vr_idxcmp IN vr_tab_regras(vr_idxreg).first..vr_tab_regras(vr_idxreg).last LOOP
            -- buscar campo na linha
            vr_dscampo_linha := substr(pr_dslinha,vr_tab_regras(vr_idxreg)(vr_idxcmp).nrposicao_inicial ,
                                                  vr_tab_regras(vr_idxreg)(vr_idxcmp).qtdposicoes);
                                                 
            -- comparar campo com a informacao definina para identificar o tipo de registro
            IF vr_dscampo_linha = vr_tab_regras(vr_idxreg)(vr_idxcmp).dsidentificador_registro THEN
              -- setar como verdadeiro e verificar se tem outro campo
              vr_flgregra := TRUE;
            ELSE
              -- setar como falso e verificar o proximo tipo de registro
              vr_flgregra := FALSE;
              EXIT;  
            END IF;                     
          END LOOP;
         
          -- se já encontrou sair do loop
          IF vr_flgregra THEN
            vr_tpregistro := vr_idxreg;
            EXIT;
          END IF;
               
          vr_idxreg := vr_tab_regras.next(vr_idxreg);
        END LOOP;
        
        RETURN TRIM(vr_tpregistro);
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Não foi possivel definir layout para a linha: '||SQLERRM;
      END fn_retorna_tpregistro;
      
    BEGIN
      vr_tab_linhas.delete;
      pr_tab_linhas.delete;
      
      -- Busca layout informado
      OPEN cr_layout;
      FETCH cr_layout INTO rw_layout; 
      IF cr_layout%NOTFOUND THEN
        -- critica layout deve ser enviado
        vr_dscritic := 'Layout para importação não encontrado';
        CLOSE cr_layout;
        RAISE vr_exc_erro;        
      END IF;
      CLOSE cr_layout;
      
      --Abrir arquivo
      gene0001.pc_abre_arquivo ( pr_nmdireto => pr_dsdireto    --> Diretório do arquivo
                                ,pr_nmarquiv => pr_nmarquiv    --> Nome do arquivo
                                ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_ind_arquiv  --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);  --> Erro
                      
      IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
      
      --> Carregar layout que serao utilizados
      pc_carrega_layouts(pr_idlayout => rw_layout.idlayout);
      
      BEGIN
        LOOP
          -- Verifica se o arquivo está aberto
          IF utl_file.IS_OPEN(vr_ind_arquiv) THEN
          
            -- incrementar contador da linha
            vr_contlin := vr_contlin + 1;
            
            -- Ler linha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv --> Handle do arquivo aberto
                                        ,pr_des_text => vr_dslinha);  --> Texto lido
      
            --> Identificar layout a ser utilizado(multiplos layouts)
            vr_tpregistro := NULL;
            vr_tpregistro := fn_retorna_tpregistro ( pr_dslinha  => vr_dslinha,
                                                     pr_dscritic => vr_dscritic);
                                                   
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
                                
            IF TRIM(vr_tpregistro) IS NULL THEN
              vr_dscritic := 'Nao foi possivel definir layout para a linha';
              RAISE vr_exc_erro;
            END IF;
            
            vr_tab_linhas(vr_contlin)('$LAYOUT$').texto := vr_tpregistro;
            vr_tab_linhas(vr_contlin)('$LINHA$').texto  := vr_dslinha;
            
            --> Extrair os campos da linha e popular a temptable de retorno
            IF TRIM(rw_layout.dsdelimitador) IS NULL THEN 
              --> De forma posicional
              FOR i IN 1..vr_tab_layouts(vr_tpregistro).count LOOP             
            
                -- buscar texto conforme posicionamento no layout     
                vr_textarq := substr(vr_dslinha,vr_tab_layouts(vr_tpregistro)(i).nrposicao_inicial ,
                                                vr_tab_layouts(vr_tpregistro)(i).qtdposicoes );
                
                vr_nmcampo   := vr_tab_layouts(vr_tpregistro)(i).nmcampo;
                vr_dsformato := vr_tab_layouts(vr_tpregistro)(i).dsformato;
                
                -- tratar texto conforme layout e incluir na temptble de retorno
                BEGIN
                  CASE vr_tab_layouts(vr_tpregistro)(i).tpdado 
                    WHEN 'D' THEN
                      -- tratar formato de data
                      vr_tab_linhas(vr_contlin)(vr_nmcampo).data := to_date(vr_textarq,vr_dsformato);
                    WHEN 'N' THEN
                      vr_textarq := nvl(LTRIM(vr_textarq),0);
                      -- tratar decimais
                      vr_tab_linhas(vr_contlin)(vr_nmcampo).numero := to_number(vr_textarq) / to_number(vr_tab_layouts(vr_tpregistro)(i).vldivisao); --dividir para obter decimais
                    ELSE
                      -- Tratar texto 
                      vr_tab_linhas(vr_contlin)(vr_nmcampo ).texto := (vr_textarq);  
                  END CASE;
                EXCEPTION 
                  WHEN OTHERS THEN
                      vr_tab_linhas(vr_contlin)('$ERRO$').texto := 'Erro ao ler o campo '||vr_nmcampo ||': '||SQLERRM;
                END;                                
              END LOOP;
              --> Fim leitura posicional
              
            ELSE
              --> OU POR DEMILITADOR       
              -- Quebrar linha do arquivo pelo delimitador
              vr_split := gene0002.fn_quebra_string(pr_string => vr_dslinha, 
                                                    pr_delimit => rw_layout.dsdelimitador);
              
              FOR i IN vr_tab_layouts(vr_tpregistro).first..vr_tab_layouts(vr_tpregistro).last LOOP     
                      
                vr_nmcampo   := vr_tab_layouts(vr_tpregistro)(i).nmcampo;  
                vr_dsformato := vr_tab_layouts(vr_tpregistro)(i).dsformato;
                
                IF vr_split.exists(i) THEN
                  -- buscar texto conforme posicionamento no layout     
                  vr_textarq := vr_split(i);
                ELSE
                  vr_tab_linhas(vr_contlin)('$ERRO$').texto := 'Campo '||vr_nmcampo ||' não encontrado na linha.';  
                  --> Em caso de erro deve parar de ler a linha e retornar para o chamador
                  EXIT;
                END IF;
                
                -- tratar texto conforme layout e incluir na temptble de retorno
                BEGIN
                  CASE vr_tab_layouts(vr_tpregistro)(i).tpdado 
                    WHEN 'D' THEN
                      -- tratar formato de data
                      vr_tab_linhas(vr_contlin)(vr_nmcampo).data := to_date(vr_textarq,vr_dsformato);
                    WHEN 'N' THEN
                      vr_textarq := replace(replace(nvl(LTRIM(vr_textarq),0),chr(10)),chr(13));
                      -- testar se é numerico
                      vr_tab_linhas(vr_contlin)(vr_nmcampo).numero := to_number(vr_textarq);
                      -- converter formato corretamente
                      vr_tab_linhas(vr_contlin)(vr_nmcampo).numero := gene0002.fn_char_para_number(vr_textarq);
                      
                    ELSE
                      -- Tratar texto 
                      vr_tab_linhas(vr_contlin)(vr_nmcampo ).texto := (vr_textarq);  
                  END CASE;
                EXCEPTION 
                  WHEN OTHERS THEN
                      vr_tab_linhas(vr_contlin)('$ERRO$').texto := 'Erro ao ler o campo '||vr_nmcampo ||': '||SQLERRM||'- '||vr_textarq;
                      --> Em caso de erro deve parar de ler a linha e retornar para o chamador para ler a proxima linha
                      EXIT;
                END;                                
              END LOOP;
              --Fim leitura delimitador;
            END IF;                                                           
      
          END IF;
        END LOOP;
      EXCEPTION
        WHEN no_data_found THEN
          -- Fechar o arquivo
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
      END; 
      
      pr_tab_linhas := vr_tab_linhas;
    
    EXCEPTION
      WHEN vr_exc_erro  THEN
         pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
         pr_dscritic := 'Erro ao importar linhas do arquivo '||pr_nmarquiv||': '||SQLERRM;
    END pc_importa_arq_layout;
    
END  gene0009;
/

