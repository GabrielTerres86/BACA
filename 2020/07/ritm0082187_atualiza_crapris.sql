/*ritm0082187 - Miguel - 01/07/2020
 tem como objetivo atualizar a dtvencop, da tabela crapris
 pois, com o adiantamento das parcelas devido ao covid, em alguns contratos,
 a data que está sendo gravada na tabela está sendo calculada de forma incorreta.
 
 Neste baca, será atualizada a data e atualizado o arquivo de rollbakc que se encontra
 em cpd/bacas/ritm0082187/ROLLBACK_crapris
*/
DECLARE 



  CURSOR cr_adiantamentos IS
    SELECT t.cdcooper
           , t.nrdconta
           , t.nrctremp
           , r.dtvencop vencto_ris
           , (SELECT MAX(p.dtvencto)
              FROM crappep p
              WHERE p.cdcooper = t.cdcooper
              AND p.nrdconta = t.nrdconta
              AND p.nrctremp = t.nrctremp) vencto_pep
    FROM crapepr t
       , crawepr w
       , crapris r
    WHERE w.cdcooper = t.cdcooper
      AND w.nrdconta = t.nrdconta
      AND w.nrctremp = t.nrctremp
      AND r.cdcooper = t.cdcooper
      AND r.nrdconta = t.nrdconta
      AND r.nrctremp = t.nrctremp
      AND r.dtrefere = '30/06/2020'
      AND r.cdorigem = 3
      AND t.tpemprst > 0 -- Sem ser TR
      AND t.qtpreemp > 1 -- Mais de uma parcela
      AND ((SELECT MAX(p.dtvencto)  -- Onde a última parcela da PEP seja maior que a parcela calculada na ris
                FROM crappep p
                WHERE p.cdcooper = t.cdcooper
                AND p.nrdconta = t.nrdconta
                AND p.nrctremp = t.nrctremp) > r.dtvencop
      );
  
  rw_adiantamentos cr_adiantamentos%ROWTYPE;

-- Variaveis de manipulacao de arquivo 
  vr_arq_path  VARCHAR2(1000):= gene0001.fn_diretorio(pr_tpdireto => 'M', 
                                                      pr_cdcooper => 0, 
                                                      pr_nmsubdir => 'cpd/bacas/ritm0082187'); 

  vr_nmarqbkp  VARCHAR2(100) := 'ROLLBACK_crapris.txt';

 -- Variaveis de arquivo rollback
  vr_des_rollback_xml         CLOB;
  vr_texto_rb_completo  VARCHAR2(32600);
  
-- Subrotinas para escrever os logs
  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;
 

BEGIN 
  -- Inicializar o CLOB do rollback
  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;


  FOR rw_adiantamentos IN cr_adiantamentos LOOP
     
      UPDATE crapris ris
         SET ris.dtvencop = rw_adiantamentos.vencto_pep
       WHERE ris.cdcooper = rw_adiantamentos.cdcooper
         AND ris.nrdconta = rw_adiantamentos.nrdconta
         AND ris.nrctremp = rw_adiantamentos.nrctremp
         AND ris.dtrefere = '30/06/2020'
         AND ris.cdorigem = 3;
      
      pc_escreve_xml_rollback('UPDATE crapris ris '||                    
                       ' SET ris.dtvencop = ''' || to_char(rw_adiantamentos.vencto_ris, 'DD/MM/YYYY') || ''' ' ||
                       ' WHERE ris.cdcooper = ' || rw_adiantamentos.cdcooper ||
                       ' AND ris.nrdconta = ' || rw_adiantamentos.nrdconta ||
                       ' AND ris.nrctremp = ' || rw_adiantamentos.nrctremp ||
                       ' AND ris.dtvencop = ''' || to_char(rw_adiantamentos.vencto_pep, 'DD/MM/YYYY') || ''' ' ||
                       ' AND ris.dtrefere = ''30/06/2020'' ' ||
                       ' AND ris.cdorigem = 3;' ||chr(10));                 
         
  END LOOP; 

        
  pc_escreve_xml_rollback('COMMIT;');
  pc_escreve_xml_rollback(' ',TRUE);
             
  -- Tansforma em arquivo de bkp
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_rollback_xml, vr_arq_path, vr_nmarqbkp, NLS_CHARSET_ID('UTF8'));

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_rollback_xml);
  dbms_lob.freetemporary(vr_des_rollback_xml);
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro inesperado 2' || SQLERRM);    
    cecred.pc_internal_exception;
    ROLLBACK;
END;
