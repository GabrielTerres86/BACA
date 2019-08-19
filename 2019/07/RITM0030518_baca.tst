PL/SQL Developer Test script 3.0
125
-- Created on 24/07/2019 by F0030344 
DECLARE  

  CURSOR cr_crapcop IS 
    SELECT *
      FROM crapcop c
     WHERE c.flgativo = 1
    ORDER BY c.cdcooper;


  CURSOR cr_crapcob(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_dtmvtolt crapcob.dtmvtolt%TYPE) IS
    SELECT *
      FROM crapcob c  
     WHERE c.cdcooper = pr_cdcooper
       AND c.dtdpagto IS NOT NULL
       AND c.dtvencto < c.dtdpagto
       AND c.vldpagto > c.vltitulo
       AND c.incobran = 5
       AND (c.vljurdia > 0
         OR c.vlrmulta > 0)
       AND c.dtmvtolt BETWEEN pr_dtmvtolt AND '29/07/2019'; 
  
  vr_vldifere crapcob.vltitulo%TYPE;
  
  vr_vlrmulta    crapcob.vltitulo%TYPE := 0;
  vr_vlrjuros    crapcob.vltitulo%TYPE := 0;
  vr_vlfatura    crapcob.vltitulo%TYPE := 0;
  vr_vldescto    crapcob.vltitulo%TYPE := 0;
  vr_vlabatim    crapcob.vltitulo%TYPE := 0;
   
  vr_dscritic    crapcri.dscritic%TYPE;
  
  
  vr_dsstatus VARCHAR2(25);
  
  vr_arq_path        VARCHAR2(1000);        --> Diretorio que sera criado o relatorio
  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);
  
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;  
  
BEGIN 
  
  vr_arq_path := '/micros/cecred/tiago/'; 
  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;

  pc_escreve_xml( 'COOOPERATIVA;CONTA;DOCUMENTO;CONVENIO;VALOR TITULO;VALOR PAGO;VALOR ESPERADO MULTA JUROS;VALOR PAGO JUROS MULTA;DIFERENCA JUROS MULTA COBRADO REAIS;VALOR DESCONTO;VALOR ABATIMENTO;STATUS'||chr(10));
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
     FOR rw_crapcob IN cr_crapcob(pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_dtmvtolt => '01/05/2019') LOOP
       
    
      vr_vldifere:= 0;
      vr_vlrjuros:= 0;
      vr_vlrmulta:= 0;
      vr_vldescto:= 0;
      vr_vlabatim:= rw_crapcob.vlabatim;
      vr_vlfatura:= rw_crapcob.vltitulo;

      /* calculo de abatimento deve ser antes da aplicacao de juros e multa */
      IF nvl(vr_vlabatim,0) > 0 THEN
        --Diminuir valor do abatimento na fatura
        vr_vlfatura:= nvl(vr_vlfatura,0) - nvl(vr_vlabatim,0);
      END IF;
      /* trata o desconto se concede apos o vencimento */
      IF rw_crapcob.cdmensag = 2 THEN
        --Valor desconto recebe valor bordero cobranca
        vr_vldescto:= rw_crapcob.vldescto;
        --Diminuir valor dodesconto na fatura
        vr_vlfatura:= nvl(vr_vlfatura,0) - nvl(vr_vldescto,0);
      END IF;

      cxon0014.pc_calcula_vlr_titulo_vencido(pr_vltitulo => vr_vlfatura
                                            ,pr_tpdmulta => rw_crapcob.tpdmulta
                                            ,pr_vlrmulta => rw_crapcob.vlrmulta
                                            ,pr_tpjurmor => rw_crapcob.tpjurmor
                                            ,pr_vljurdia => rw_crapcob.vljurdia
                                            ,pr_qtdiavenc => (rw_crapcob.dtdpagto - rw_crapcob.dtvencto)
                                            ,pr_vlfatura => vr_vlfatura
                                            ,pr_vlrmulta_calc => vr_vlrmulta
                                            ,pr_vlrjuros_calc => vr_vlrjuros
                                            ,pr_dscritic => vr_dscritic);
       
       
       vr_vldifere := rw_crapcob.vldpagto - vr_vlfatura;
 
       --verificar diferenca entre os pagamentos e os juros esperados
       IF vr_vldifere <> 0  THEN
       
          vr_dsstatus := 'LIQUIDADO';
  
          IF rw_crapcob.insitcrt = 3 THEN
             vr_dsstatus := 'LIQUIDADO EM CARTORIO';
          END IF;
        
          pc_escreve_xml( rw_crapcob.cdcooper ||';'|| rw_crapcob.nrdconta ||';'|| rw_crapcob.nrdocmto || ';' || rw_crapcob.nrcnvcob || ';' ||
                          rw_crapcob.vltitulo ||';'|| rw_crapcob.vldpagto ||';'||
                          (vr_vlrjuros + vr_vlrmulta) ||';'|| ( (vr_vlrjuros + vr_vlrmulta) - (vr_vldifere * -1)) ||';'|| TO_CHAR(vr_vldifere * -1) ||';'||
                          vr_vldescto||';'||vr_vlabatim||';'||vr_dsstatus ||';'|| chr(10) );
       END IF;         
     
     END LOOP;
    
  END LOOP;
  

  pc_escreve_xml(' ',TRUE);
  
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_xml, vr_arq_path, 'RL_PAGTOS_DIVERGENTES.txt', NLS_CHARSET_ID('UTF8'));
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);  

END;
0
0
