PL/SQL Developer Test script 3.0
109
-- Created on 24/07/2019 by F0030344 
DECLARE  

  CURSOR cr_crapcop IS 
    SELECT *
      FROM crapcop c
     WHERE c.flgativo = 1
      AND cdcooper = 1;


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
  
  vr_vlrmulta crapcob.vltitulo%TYPE;
  vr_vljurdia crapcob.vltitulo%TYPE;
  vr_vldifere crapcob.vltitulo%TYPE;
  
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

  pc_escreve_xml( 'COOOPERATIVA;CONTA;DOCUMENTO;CONVENIO;VALOR TITULO;VALOR PAGO;VALOR ESPERADO MULTA JUROS;VALOR PAGO JUROS MULTA;DIFERENCA JUROS MULTA COBRADO REAIS;'||chr(10));
  
  FOR rw_crapcop IN cr_crapcop LOOP
    
     FOR rw_crapcob IN cr_crapcob(pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_dtmvtolt => '01/05/2019') LOOP
       
       
       vr_vlrmulta := 0;
       vr_vljurdia := 0;
       vr_vldifere := 0;
       
       --calcular valor multa esperado
       IF rw_crapcob.vlrmulta > 0 THEN         
       
          IF rw_crapcob.tpdmulta = 1 THEN --valor fixo reais
             vr_vlrmulta := rw_crapcob.vlrmulta;            
          ELSE
            IF rw_crapcob.tpdmulta = 2 THEN --valor percentual
               vr_vlrmulta := rw_crapcob.vltitulo * (rw_crapcob.vlrmulta / 100);
            END IF;  
          END IF;
       
       END IF;     
     

       --calcular valor juros esperado
       IF rw_crapcob.vljurdia > 0 THEN         
       
          IF rw_crapcob.tpjurmor = 1 THEN --valor fixo reais
             vr_vljurdia := rw_crapcob.vljurdia * (rw_crapcob.dtdpagto - rw_crapcob.dtvencto);            
          ELSE
            IF rw_crapcob.tpjurmor = 2 THEN --valor percentual
               vr_vljurdia := (rw_crapcob.vltitulo * ((rw_crapcob.vljurdia * (rw_crapcob.dtdpagto - rw_crapcob.dtvencto))/30))/100;
            END IF;  
          END IF;
       
       END IF;     

       vr_vldifere := rw_crapcob.vldpagto - rw_crapcob.vltitulo;
 
       --verificar diferenca entre os pagamentos e os juros esperados
       IF vr_vldifere <> (vr_vljurdia + vr_vlrmulta)  THEN
       
          pc_escreve_xml( rw_crapcob.cdcooper ||';'|| rw_crapcob.nrdconta ||';'|| rw_crapcob.nrdocmto || ';' || rw_crapcob.nrcnvcob || ';' ||
                          rw_crapcob.vltitulo ||';'|| rw_crapcob.vldpagto ||';'||
                          (vr_vljurdia + vr_vlrmulta) ||';'|| vr_vldifere ||';'|| TO_CHAR((vr_vljurdia + vr_vlrmulta) - vr_vldifere) ||';'||
                          chr(10) );
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
