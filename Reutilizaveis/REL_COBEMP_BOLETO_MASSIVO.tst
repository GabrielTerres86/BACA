PL/SQL Developer Test script 3.0
185
-- Created on 23/11/2018 by F0030344 
-- Relatorio simplicado do retorno da imoprtação de geração massiva de boletagem pela COBEMP
DECLARE  
  vr_numarqvo INTEGER := 39;
  vr_cdbarras VARCHAR2(2000);
  vr_lindigit VARCHAR2(2000);

  vr_gerarelato BOOLEAN := FALSE;
    
  vr_vltitulo  VARCHAR2(100);
  vr_vldevedor VARCHAR2(100);

  vr_arquivo      CLOB;
  vr_dsnmarq      VARCHAR2(100);
  vr_caminho_arq  VARCHAR2(200);

  vr_cdagediv NUMBER;
  vr_retorno  BOOLEAN;
  vr_dsagebnf VARCHAR2(10);

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;  
  vr_dscritic     VARCHAR2(10000);

  -- Cursor para consultar arquivo
  CURSOR cr_crapcob(pr_idarquiv IN tbrecup_cobranca.idarquivo%TYPE) IS       
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrdconta_cob
          ,epr.nrctremp
          ,imp.nrcpfaval
          ,DECODE(imp.tpenvio,1,'E-mail',2,'SMS',3,'Carta') tpenvio
          ,cob.vltitulo
          ,cob.dtvencto
          ,cob.nrcnvcob
          ,cob.nrdocmto
          ,imp.nrddd_envio
          ,imp.nrfone_envio
          ,imp.dsemail_envio
          ,imp.dsendereco_envio
          ,cob.cdmensag
          ,cob.tpjurmor
          ,cob.flgdprot
          ,cob.flserasa
          ,cob.tpdmulta
          ,cob.qtdiaprt
          ,cob.qtdianeg
          ,cob.vljurdia
          ,cob.vlrmulta
          ,cob.dsdinstr
          ,cob.nrnosnum
          ,cob.cdbandoc
          ,cob.cdcartei
          ,sab.nmdsacad
          ,sab.nrinssac
          ,cop.cdagectl
          ,epr.vldevedor
          ,imp.dscep_envio
      FROM tbrecup_boleto_import imp
          ,tbrecup_cobranca epr
          ,crapcob cob
          ,crapcco cco
          ,crapsab sab
          ,crapcop cop
     WHERE imp.idarquivo = pr_idarquiv
       AND epr.idarquivo = imp.idarquivo
       AND epr.idboleto  = imp.idboleto
       AND epr.tpproduto = 0
       AND cco.cdcooper = epr.cdcooper
       AND cco.nrconven = epr.nrcnvcob                         
       AND cop.cdcooper = epr.cdcooper
       AND cob.cdcooper = epr.cdcooper
       AND cob.nrdconta = epr.nrdconta_cob
       AND cob.cdbandoc = cco.cddbanco
       AND cob.nrdctabb = cco.nrdctabb
       AND cob.nrcnvcob = epr.nrcnvcob
       AND cob.nrdocmto = epr.nrboleto
     --  AND cob.incobran = 0 -- Apenas titulos em aberto
       AND sab.cdcooper = cob.cdcooper
       AND sab.nrdconta = cob.nrdconta
       AND sab.nrinssac = cob.nrinssac
       ORDER BY cob.nrdconta, cob.nrctremp;  


  --Escrever no arquivo CLOB
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
  BEGIN
    dbms_lob.writeappend(vr_arquivo,length(pr_des_dados),pr_des_dados);
  END;
  
  
BEGIN 
  
  vr_gerarelato := FALSE;    

  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_arquivo, TRUE);
  dbms_lob.open(vr_arquivo, dbms_lob.lob_readwrite);

  FOR rw_crapcob IN cr_crapcob(pr_idarquiv => vr_numarqvo) LOOP
  
    -- Calcula digito agencia
    vr_cdagediv := rw_crapcob.cdagectl * 10;
    vr_retorno  := gene0005.fn_calc_digito(pr_nrcalcul => vr_cdagediv, pr_reqweb => FALSE);
    vr_dsagebnf := gene0002.fn_mask(vr_cdagediv, '9999-9');
  
    -- Monta codigo de barra
    COBR0005.pc_calc_codigo_barras ( pr_dtvencto => rw_crapcob.dtvencto
                                    ,pr_cdbandoc => rw_crapcob.cdbandoc
                                    ,pr_vltitulo => rw_crapcob.vltitulo
                                    ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                    ,pr_nrcnvceb => 0
                                    ,pr_nrdconta => rw_crapcob.nrdconta_cob
                                    ,pr_nrdocmto => rw_crapcob.nrdocmto
                                    ,pr_cdcartei => rw_crapcob.cdcartei
                                    ,pr_cdbarras => vr_cdbarras);
          
    -- Monta Linha Digitavel
    COBR0005.pc_calc_linha_digitavel(pr_cdbarras => vr_cdbarras,
                                     pr_lindigit => vr_lindigit);
                                           
    vr_vltitulo  :=  TO_CHAR(rw_crapcob.vltitulo,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') ;
    vr_vldevedor :=  TO_CHAR(rw_crapcob.vldevedor,'FM9G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') ;
  
  
    /*Escreve relatorio no xml*/
    pc_escreve_xml(rw_crapcob.cdcooper || ';' ||
                   rw_crapcob.nrdconta || ';' ||
                   rw_crapcob.nrctremp || ';' ||
                   substr(rw_crapcob.nmdsacad,1,40) || ';' ||
                   vr_lindigit || ';' ||
                   to_char(rw_crapcob.dtvencto,'DD/MM/RRRR') || ';' ||
                   rw_crapcob.dsdinstr ||
                   REPLACE(rw_crapcob.dsendereco_envio,CHR(13),'') || ';' ||
                   REPLACE(rw_crapcob.dscep_envio,CHR(13),'') || ';' ||
                   vr_vldevedor || ';' ||
                   vr_vltitulo || ';' ||
                   '(' || rw_crapcob.nrddd_envio || ') ' || gene0002.fn_mask(rw_crapcob.nrfone_envio,'99999-9999') || ';' ||
                   rw_crapcob.nrnosnum || ';' ||
                   rw_crapcob.cdbandoc || ';' ||
                   vr_dsagebnf || ';' ||
                   rw_crapcob.cdcartei || ';' ||
                   rw_crapcob.nrdconta_cob || ';' ||
                   rw_crapcob.nrinssac || ';' ||
                   rw_crapcob.nrdocmto || ';' ||
                   'DM' || '|' || CHR(13));
                   
    vr_gerarelato := TRUE;    
    
  END LOOP;


  /*Geração do arquivo fisico na pasta*/
  vr_dsnmarq := 'BPC_CECRED_' || lpad(vr_numarqvo,6,0) || '.csv';  
  
  IF vr_gerarelato THEN
        
    -- Busca o diretorio da cooperativa conectada
    vr_caminho_arq := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => 0
                                               ,pr_cdacesso => 'ROOT_MICROS')||'cecred/rodrigo/';

    --vr_caminho_arq := '/usr/coopd/sistemad/equipe/tiago/';
    -- Escreve o clob no arquivo físico
    gene0002.pc_clob_para_arquivo(pr_clob => vr_arquivo
                                 ,pr_caminho => vr_caminho_arq
                                 ,pr_arquivo => vr_dsnmarq
                                 ,pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;        
    
  END IF;
  
  dbms_output.put_line('Finalizou com sucesso');
  
EXCEPTION
  WHEN vr_exc_saida THEN
     dbms_output.put_line('Erro: exc_saida');
    ROLLBACK;
  WHEN OTHERS THEN
     dbms_output.put_line('Erro: Others');
    ROLLBACK; 
  
END;
0
0
