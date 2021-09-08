DECLARE
  CURSOR cr_parcelas IS
    SELECT *
      FROM tbepr_consignado_pagamento tcp
     WHERE tcp.cdcooper = 13
       AND tcp.nrdconta = 150479
       AND tcp.nrctremp = 115328
       AND tcp.nrparepr = 3
       AND tcp.idsequencia = 357476;
  rw_parcelas cr_parcelas%ROWTYPE;
  vr_xml_parcela  VARCHAR2(32600);
  vr_tipo_pagto   VARCHAR2(300);
  vr_idpagamento  tbepr_consignado_pagamento.idsequencia%TYPE;
  vr_motenvio     VARCHAR2(50);
  vr_dsxmlali     XMLTYPE;
  vr_dscritic     crapcri.dscritic%TYPE;
  vr_exc_erro     EXCEPTION;
BEGIN
  OPEN cr_parcelas;
  LOOP
    FETCH cr_parcelas INTO rw_parcelas;
    EXIT WHEN cr_parcelas%NOTFOUND;
    -- Verifica se o valor que esta sendo pago é total ou parcial
    -- Compara o valor calculado na tela com o valor da parcela
    IF  rw_parcelas.vlpagpar = rw_parcelas.vlparepr THEN  
      vr_tipo_pagto := ' <valor>'||trim(to_char(rw_parcelas.vlpagpar,'999999990.00'))||'</valor>' ;
    ELSE                      
      vr_tipo_pagto:= ' <valorParcial>'||trim(to_char(rw_parcelas.vlpagpar,'999999990.00'))||'</valorParcial>';
    END IF;
    vr_idpagamento := NULL;
    vr_xml_parcela:= vr_xml_parcela||
                     ' <parcela>
                         <dataEfetivacao>'||to_char(/*pr_dtmvtolt*/rw_parcelas.dtmvtolt,'yyyy-mm-dd')||'T'||to_char(sysdate,'hh24:mi:ss')||'</dataEfetivacao> 
                         <dataVencimento>'||to_char(rw_parcelas.dtvencto,'yyyy-mm-dd')||'</dataVencimento>
                         <identificador>'||rw_parcelas.idseqpagamento||'</identificador>'||
                         vr_tipo_pagto|| 
                      '</parcela>';
  END LOOP;
  vr_motenvio := NULL;
  -- Gera o XML do pagamento a ser gravado no evento SOA
  empr0020.pc_gera_xml_pagamento_consig(pr_cdcooper     => rw_parcelas.cdcooper, -- código da cooperativa
                                        pr_nrdconta     => rw_parcelas.nrdconta, -- Número da conta
                                        pr_nrctremp     => rw_parcelas.nrctremp, -- Número do contrato de emprestimo
                                        pr_xml_parcelas => vr_xml_parcela, -- xml com as parcelas
                                        pr_tpenvio      => 1,             -- tipo de envio 1 - INSTALLMENT_SETTLEMENT
                                        pr_tptransa     => 'DEBITO',      --
                                        pr_motenvio     => vr_motenvio,
                                        pr_dsxmlali     => vr_dsxmlali, -- XML de saida do pagamento
                                        pr_dscritic     => vr_dscritic); 

  -- Tratar saida com erro                           
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
  CLOSE cr_parcelas;
	
	INSERT INTO TBGEN_EVENTO_SOA(IDEVENTO
	                            ,CDCOOPER
															,NRDCONTA
															,NRCTRPRP
															,TPEVENTO
															,TPRODUTO_EVENTO
															,TPOPERACAO
															,DHOPERACAO
															,DSPROCESSAMENTO
															,DSSTATUS
															,DHEVENTO
															,DSERRO
															,NRTENTATIVAS
															,DSCONTEUDO_REQUISICAO
															) VALUES(
															 NULL
															,rw_parcelas.cdcooper
															,rw_parcelas.nrdconta
															,rw_parcelas.nrctremp
															,'PAGTO_PAGAR'
															,'CONSIGNADO'
															,'INSERT'
															,SYSDATE
															,NULL
															,NULL
															,NULL
															,NULL
															,NULL
															,vr_dsxmlali.getClobVal()
															);
  
  --dbms_output.put_line(vr_dsxmlali.getClobVal());
	COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
		ROLLBACK;
    dbms_output.put_line('Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
		ROLLBACK;
    dbms_output.put_line('Erro 2: ' || SQLERRM);
END;  
