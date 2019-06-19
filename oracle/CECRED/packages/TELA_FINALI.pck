CREATE OR REPLACE PACKAGE CECRED.tela_finali IS
  
  /* Remover linhas selecionadas */
  PROCEDURE pc_excluir_lcr_finali(pr_cdfinemp IN craplch.cdfinemp%TYPE --> Finalidade a remover
                                 ,pr_dslstlin IN VARCHAR2              --> Lista de Linhas 
                                 -- Interface mensageria
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2); --> Erros do processo

END tela_finali;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_finali IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_FINALI
  --  Sistema  : Ayllos Web
  --  Autor    : Marcos Martini
  --  Data     : Fevereiro - 2019.                Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela FINALI
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

    /* Remover linhas selecionadas */
  PROCEDURE pc_excluir_lcr_finali(pr_cdfinemp IN craplch.cdfinemp%TYPE --> Finalidade a remover
                                 ,pr_dslstlin IN VARCHAR2              --> Lista de Linhas 
                                 -- Interface mensageria
                                 ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa: pc_excluir_lcr_finali         Antiga: b1wgen0167.p --> excluir-lcr-finali
    Sistema : Ayllos Web
    Autor   : Marcos Martini
    Data    : Fevereiro - 2019                Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para remover o vinculo das linhas a finalidade
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
     
      -- Variaveis da mensageria
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      
      -- Checar se a finalidade passada é pre-aprovado, e alguma das linhas a eliminar
      -- esteja vinculada a alguma carga de pre-aprovado ativa
      CURSOR cr_finpre(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT DISTINCT cpa.cdlcremp
          FROM crappre              pre
              ,crapcpa              cpa
              ,tbepr_carga_pre_aprv car
         WHERE car.idcarga = cpa.iddcarga
           AND car.cdcooper = cpa.cdcooper
           AND cpa.cdcooper = pre.cdcooper
           AND cpa.tppessoa = pre.inpessoa
           AND pre.cdcooper = pr_cdcooper
           AND pre.cdfinemp = pr_cdfinemp
           AND '|'|| pr_dslstlin ||'|' LIKE ('%|' || cpa.cdlcremp || '|%')
           AND car.flgcarga_bloqueada = 0 -- Liberada
           AND NVL(car.dtfinal_vigencia,TRUNC(SYSDATE)) >= TRUNC(SYSDATE) -- Vigente
           AND cpa.cdsituacao = 'A'; -- Somente cargas aceitas
      -- Lista de linhas
      vr_dslinha VARCHAR2(4000);
      
    BEGIN
      -- Não precisa executar pois neste processo não utilizamos estes dados
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Tratar parametros obrigatorios
      IF pr_cdfinemp IS NULL THEN
        vr_dscritic := 'Finalidade nao recebida!';
        RAISE vr_exc_saida;
      END IF;
      IF pr_dslstlin IS NULL THEN
        vr_dscritic := 'Linha(s) nao recebida(s)!';
        RAISE vr_exc_saida;
      END IF;
      
      -- Garantir que a linha não esteja vinculada a nenhuma carga ativa 
      FOR rw_fin IN cr_finpre(vr_cdcooper) LOOP
        vr_dslinha := vr_dslinha||','||rw_fin.cdlcremp;
      END LOOP;
      -- Remover a primeira virgula
      vr_dslinha := ltrim(vr_dslinha,',');
      
      -- Se existe alguma linha
      IF vr_dslinha IS NOT NULL THEN
        vr_dscritic := '<![CDATA[A(s) seguinte(s) linha(s) abaixo nao podem ser removidas pois estao<br>vinculada(s) em cargas de Pre-Aprovado ativas:<br>'||vr_dslinha||']]>';
        RAISE vr_exc_saida;
      END IF;
      
      -- Efetuar o delete prevendo que podemos receber mais de uma linha separada por Pipe " | "
      BEGIN
        DELETE 
          FROM craplch lch
         WHERE lch.cdcooper = vr_cdcooper
           AND lch.cdfinemp = pr_cdfinemp
           AND '|'|| pr_dslstlin ||'|' LIKE ('%|' || lch.cdlcrhab || '|%');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao eliminar o vinculo Finalidade X Linha de Credito: '||SQLERRM;     
          RAISE vr_exc_saida;
      END;
      
      -- Gravar
      COMMIT;
    
    EXCEPTION
      WHEN vr_exc_saida THEN      
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;      
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela FINALI: ' || SQLERRM;      
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
        ROLLBACK;
    END;
  
  END pc_excluir_lcr_finali;

END tela_finali;
/
