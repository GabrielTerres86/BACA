DECLARE
    -- INC0117012 - 278037- Contrato com Saldo Zero
    
    -- Armazena coop, conta, contrato, IOF, qtd meses para avancar parcela
    vr_aux_reg VARCHAR2(10000) := '1;13665464;4912942;1195.82;0 | ' ||
                                  '10;210153;35037;87.31;0';
                                                             
    vr_aux_dtcalc VARCHAR2(100);
    vr_aux_dtparc VARCHAR2(100);
    vr_aux_diacar VARCHAR2(100);                                             
    vr_aux_indic  gene0002.typ_split;
    vr_aux_unico  gene0002.typ_split;
    vr_indexemit  INTEGER;
    vr_indexunic  INTEGER;
    vr_tagiof     VARCHAR2(1000);
    vr_iddcle     VARCHAR2(1000);
    vr_iddppr     VARCHAR2(1000);
    vr_idcare     VARCHAR2(1000);
    vr_aux_dtvencto DATE;
    vr_xml_final  CLOB;
    vr_xml_um     CLOB;
    vr_xml_dois   CLOB;
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
         AND a.tpevento = 'EFETIVA_PROPOSTA'
         AND ROWNUM = 1
         ORDER BY a.idevento;
       rw_evento_soa cr_evento_soa%ROWTYPE;
 

    CURSOR cr_crappep(pr_cdcooper crappep.cdcooper%TYPE
                     ,pr_nrdconta crappep.nrdconta%TYPE
                     ,pr_nrctremp crappep.nrctremp%TYPE) IS  
      SELECT a.dtvencto 
        FROM crappep a 
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta  
         AND a.nrctremp = pr_nrctremp
         AND a.nrparepr = 1; 
   rw_crappep cr_crappep%ROWTYPE;
   
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
        ELSE
          CLOSE cr_evento_soa; 
        END IF;     
        vr_aux_xml := rw_evento_soa.dsconteudo_requisicao;
               
        OPEN cr_crappep(pr_cdcooper => vr_aux_unico(1),
                        pr_nrdconta => vr_aux_unico(2),
                        pr_nrctremp => vr_aux_unico(3));
        FETCH cr_crappep
         INTO rw_crappep;
        IF cr_crappep%NOTFOUND THEN
          CLOSE cr_crappep;
          vr_dscritic := 'Sem parcela um registrada';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crappep;
        END IF;   
        
        --Localiza tag tributoIOFValor no xml 
        vr_tagiof := SUBSTR(vr_aux_xml,
                     INSTR(vr_aux_xml, '<tributoIOFValor>'),
                     (INSTR(vr_aux_xml, '</tributoIOFValor>', -1) - INSTR(vr_aux_xml, '<tributoIOFValor>')));
                     
        --Localiza tag dataCalculoLegado no xml 
        vr_iddcle := SUBSTR(vr_aux_xml,
                     INSTR(vr_aux_xml, '<dataCalculoLegado>'),
                     (INSTR(vr_aux_xml, '</dataCalculoLegado>', -1) - INSTR(vr_aux_xml, '<dataCalculoLegado>')));             
                     
        --Localiza tag dataPrimeiraParcela no xml 
        vr_iddppr := SUBSTR(vr_aux_xml,
                     INSTR(vr_aux_xml, '<dataPrimeiraParcela>'),
                     (INSTR(vr_aux_xml, '</dataPrimeiraParcela>', -1) - INSTR(vr_aux_xml, '<dataPrimeiraParcela>')));             
        
        --dataCalculoLegado                                                       
        vr_aux_dtcalc := TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'); 
        
        --dataPrimeiraParcela
        IF NVL(vr_aux_unico(5),0) > 0 THEN 
          vr_aux_dtparc := add_months(rw_crappep.dtvencto, vr_aux_unico(5));
          
          -- Avancar data parcela na crapep
          BEGIN 
            UPDATE crappep
               SET dtvencto = add_months(dtvencto, vr_aux_unico(5))
             WHERE cdcooper = vr_aux_unico(1)
               AND nrdconta = vr_aux_unico(2)
               AND nrctremp = vr_aux_unico(3);
          EXCEPTION
            WHEN OTHERS THEN
              DBMS_OUTPUT.PUT_LINE(SQLERRM); 
              ROLLBACK;  
          END;
        ELSE
          vr_aux_dtparc := rw_crappep.dtvencto;
        END IF; 
                            
        --Remonta o xml com valores especificos     
        vr_xml_um    := REPLACE(vr_aux_xml,  vr_tagiof, '<tributoIOFValor>' || to_char(vr_aux_unico(4)));   
        vr_xml_dois  := REPLACE(vr_xml_um,  vr_iddppr, '<dataPrimeiraParcela>' || vr_aux_dtparc);
        vr_xml_final := REPLACE(vr_xml_dois,  vr_iddcle, '<dataCalculoLegado>' || vr_aux_dtcalc);

        -- gera evento soa para o pagamento de consignado
        cecred.soap0003.pc_gerar_evento_soa(pr_cdcooper               => vr_aux_unico(1)
                                           ,pr_nrdconta               => vr_aux_unico(2)
                                           ,pr_nrctrprp               => vr_aux_unico(3)
                                           ,pr_tpevento               => 'EFETIVA_PROPOSTA'
                                           ,pr_tproduto_evento        => 'CONSIGNADO'
                                           ,pr_tpoperacao             => 'INSERT'
                                           ,pr_dsconteudo_requisicao  => vr_xml_final
                                           ,pr_idevento               => vr_idevento
                                           ,pr_dscritic               => vr_dscritic);                         
       IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
       END IF;    
                         
    END LOOP;

    COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    DBMS_OUTPUT.PUT_LINE(vr_dscritic);
    ROLLBACK;     
  WHEN OTHERS THEN
    ROLLBACK;  
END;
