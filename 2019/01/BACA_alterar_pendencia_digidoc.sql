-- Created on 11/01/2020 by T0032613 
DECLARE
   -- Cursor para buscar os rep. legal/procurador que foram gerados com tpdoc errado
   CURSOR cr_contas IS
      SELECT doc.nrdconta, doc.cdcooper
        FROM crapavt avt, crapdoc doc
       WHERE avt.nrdconta = doc.nrdconta
         AND avt.cdcooper = doc.cdcooper
         AND avt.dtmvtolt = doc.dtmvtolt
         AND avt.tpctrato = 6
         AND avt.dtmvtolt > '08/10/2019'
         AND doc.tpdocmto = 8
         AND doc.flgdigit = 0  
       UNION 
      SELECT doc.nrdconta, doc.cdcooper
        FROM crapcrl crl, crapdoc doc  
       WHERE crl.cdcooper = doc.cdcooper
         AND crl.nrdconta = doc.nrdconta
         AND crl.dtmvtolt = doc.dtmvtolt
         AND crl.dtmvtolt > '08/10/2019'   
         AND doc.tpdocmto = 8
         AND doc.flgdigit = 0;
BEGIN 

   FOR contas IN cr_contas LOOP
      BEGIN
          UPDATE crapdoc doc
             SET doc.tpbxapen = 3 -- Baixa manual
           WHERE doc.nrdconta = contas.nrdconta
             AND doc.cdcooper = contas.cdcooper
             AND doc.tpdocmto = 8
             AND doc.flgdigit = 0
             AND doc.dtmvtolt > to_date('08/10/2019');
             
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error( -20001,'Erro na procedure pc_apura_tarifas_financiadas - '    ||
                    'vr_dataproc: ' || to_char(SYSDATE,'dd/mm/yyyy')  || ' / ' ||
                    'vr_dscritic: ' || 'Erro ao atualizar registros'               || ' / ' ||
                    'erro: '        || sqlerrm);         
      END;
   END LOOP;

	COMMIT;
END;       