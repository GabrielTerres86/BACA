DECLARE
    -- INC0109928 - Erro Civia - gerou arquivo com dados divergentes
    
    -- Armazena coop,conta,contrato
    vr_aux_reg VARCHAR2(10000) := '2;741000;304587 | ' ||
                                  '2;504831;303314 | ' ||
                                  '2;409960;303878 | ' ||
                                  '2;781126;273012 | ' ||
                                  '2;374733;264197 | ' ||
                                  '13;68039;51124  | ' ||
                                  '13;150991;122276| ' ||
                                  '13;78743;92507  | ' ||
                                  '13;215104;112556'; 
                             
    vr_aux_diacar INTEGER := 25; --diasCarencia
    vr_aux_dtcalc VARCHAR2(100);
    vr_aux_dtparc VARCHAR2(100);                                              
    vr_aux_indic  gene0002.typ_split;
    vr_aux_unico  gene0002.typ_split;
    vr_indexemit  INTEGER;
    vr_indexunic  INTEGER;
    vr_idprop     VARCHAR2(1000);
    vr_iddcle     VARCHAR2(1000);
    vr_iddppr     VARCHAR2(1000);
    vr_idcare     VARCHAR2(1000);
    vr_xml_final  CLOB;
    vr_xml_um     CLOB;
    vr_xml_dois   CLOB;
    vr_xml_tres   CLOB;
    vr_aux_xml    CLOB;   
    vr_dsxmlali   XMLType;
    vr_idevento   tbgen_evento_soa.idevento%type;
    vr_dscritic   VARCHAR2(1000);
    vr_exc_saida  EXCEPTION;
    
    CURSOR cr_evento_soa(pr_cdcooper TBGEN_EVENTO_SOA.cdcooper%TYPE
                        ,pr_nrdconta TBGEN_EVENTO_SOA.nrdconta%TYPE
                        ,pr_nrctrprp TBGEN_EVENTO_SOA.nrctrprp%TYPE) IS                     
      SELECT a.cdcooper
            ,a.nrdconta
            ,a.dsconteudo_requisicao
        FROM TBGEN_EVENTO_SOA a
       WHERE a.cdcooper = pr_cdcooper
         AND a.tproduto_evento = 'CONSIGNADO'
         AND a.nrdconta = pr_nrdconta 
         AND a.nrctrprp = pr_nrctrprp
         AND a.tpevento = 'EFETIVA_PROPOSTA';
       rw_evento_soa cr_evento_soa%ROWTYPE;
 
BEGIN
    vr_aux_indic := gene0002.fn_quebra_string(TRIM(vr_aux_reg),'|');    
    FOR vr_indexemit IN 1..vr_aux_indic.COUNT LOOP
        vr_aux_unico := gene0002.fn_quebra_string(vr_aux_indic(vr_indexemit),';');
        
        OPEN cr_evento_soa(pr_cdcooper => vr_aux_unico(1), 
                           pr_nrdconta => vr_aux_unico(2),
                           pr_nrctrprp => vr_aux_unico(3));
        FETCH cr_evento_soa
         INTO rw_evento_soa;
      
        IF cr_evento_soa%NOTFOUND THEN
          CLOSE cr_evento_soa;
          vr_dscritic := 'Registro nao existe na tabela tbgen_evento_soa.';
          RAISE vr_exc_saida;
        END IF;     
        vr_aux_xml := rw_evento_soa.dsconteudo_requisicao;
          
        --Localiza tag identificadorProposta no xml 
        vr_idprop := SUBSTR(vr_aux_xml,
                     INSTR(vr_aux_xml, '<identificadorProposta>'),
                     (INSTR(vr_aux_xml, '</identificadorProposta>', -1) - INSTR(vr_aux_xml, '<identificadorProposta>')));
                     
        --Localiza tag dataCalculoLegado no xml 
        vr_iddcle := SUBSTR(vr_aux_xml,
                     INSTR(vr_aux_xml, '<dataCalculoLegado>'),
                     (INSTR(vr_aux_xml, '</dataCalculoLegado>', -1) - INSTR(vr_aux_xml, '<dataCalculoLegado>')));             
                     
        --Localiza tag dataPrimeiraParcela no xml 
        vr_iddppr := SUBSTR(vr_aux_xml,
                     INSTR(vr_aux_xml, '<dataPrimeiraParcela>'),
                     (INSTR(vr_aux_xml, '</dataPrimeiraParcela>', -1) - INSTR(vr_aux_xml, '<dataPrimeiraParcela>')));             
                     
        --Localiza tag diasCarencia no xml 
        vr_idcare := SUBSTR(vr_aux_xml,
                     INSTR(vr_aux_xml, '<diasCarencia>'),
                     (INSTR(vr_aux_xml, '</diasCarencia>', -1) - INSTR(vr_aux_xml, '<diasCarencia>')));
                                  
        vr_aux_dtcalc := TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'); --dataCalculoLegado
        vr_aux_dtparc := TO_CHAR ((SYSDATE + vr_aux_diacar), 'YYYY-MM-DD'); --dataPrimeiraParcela
                           
        --Remonta o xml com valores especificos     
        vr_xml_um    := REPLACE(vr_aux_xml,  vr_idprop, '<identificadorProposta>99999999' || LPAD(vr_indexemit, 2, 0));   
        vr_xml_dois  := REPLACE(vr_xml_um,  vr_iddcle, '<dataCalculoLegado>' || vr_aux_dtcalc);
        vr_xml_tres  := REPLACE(vr_xml_dois,  vr_iddppr, '<dataPrimeiraParcela>' || vr_aux_dtparc);
        vr_xml_final := REPLACE(vr_xml_tres,  vr_idcare, '<diasCarencia>' || vr_aux_diacar);

        -- gera evento soa para o pagamento de consignado
        cecred.soap0003.pc_gerar_evento_soa(pr_cdcooper               => vr_aux_unico(1)
                                           ,pr_nrdconta               => vr_aux_unico(2)
                                           ,pr_nrctrprp               => '99999999' || LPAD(vr_indexemit, 2, 0)
                                           ,pr_tpevento               => 'EFETIVA_PROPOSTA'
                                           ,pr_tproduto_evento        => 'CONSIGNADO'
                                           ,pr_tpoperacao             => 'INSERT'
                                           ,pr_dsconteudo_requisicao  => vr_xml_final
                                           ,pr_idevento               => vr_idevento
                                           ,pr_dscritic               => vr_dscritic);                         
       IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
       END IF;   
           
       CLOSE cr_evento_soa;                   
    END LOOP;

    COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(vr_dscritic); 
  WHEN OTHERS THEN
    ROLLBACK;  
END;
