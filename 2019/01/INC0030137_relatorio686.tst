PL/SQL Developer Test script 3.0
81
-- Created on 07/01/2019 by F0030344 
DECLARE    
  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);

  vr_exc_erro EXCEPTION;


  CURSOR cr_crapslr(pr_cdcooper crapcop.cdcooper%TYPE
                   ,pr_dtsolici crapslr.dtsolici%TYPE
                   ,pr_cdrelato crapslr.cdrelato%TYPE) IS
    SELECT r.nrseqsol     
      FROM crapslr r
     WHERE r.cdcooper = pr_cdcooper 
       AND TRUNC(r.dtsolici) = TRUNC(pr_dtsolici)
       AND r.cdrelato = pr_cdrelato; 
       
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;
       
BEGIN 

  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  vr_texto_completo := NULL;

  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>'
               ||'  <crrl686>'
               ||'    <lancamentos dtmvtolt="31/12/2018">'
               ||'      <float qtdddias="2" flsldpen="S" >'
               ||'        <convenio>'
               ||'          <nrcnvcob>105020</nrcnvcob>'
               ||'          <qtdfloat>2</qtdfloat>'
               ||'          <qtdregis>5</qtdregis>'
               ||'          <vltotpag>1.965,03</vltotpag>'
               ||'          <dtcredit>02/01/2019</dtcredit>'
               ||'          <dtocorre>28/12/2018</dtocorre>'
               ||'        </convenio>'      
               ||'      </float>'
               ||'    </lancamentos>'
               ||'  </crrl686>'
               ||chr(10));        

  pc_escreve_xml(' ',TRUE);
  
  FOR rw_crapslr IN cr_crapslr(pr_cdcooper => 6
                              ,pr_dtsolici => TO_DATE('01/01/2019','DD/MM/RRRR')
                              ,pr_cdrelato => 686) LOOP
    
  
    BEGIN
      
      UPDATE crapslr 
         SET crapslr.dtiniger = NULL
            ,crapslr.dtfimger = NULL
            ,crapslr.flgerado = 'N'
            ,crapslr.dsxmldad = vr_des_xml
            ,crapslr.dserrger = NULL
       WHERE crapslr.nrseqsol = rw_crapslr.nrseqsol;           
                  
    EXCEPTION
      WHEN OTHERS THEN
        RAISE vr_exc_erro;
    END;
  
  
  END LOOP;

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);

EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Impossível reprocessar relatorio: '||sqlerrm);  
END;
0
0
