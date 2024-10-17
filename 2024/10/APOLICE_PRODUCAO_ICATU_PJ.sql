DECLARE 

  CURSOR cr_parametros IS
    SELECT p.idseqpar,
           p.cdcooper,
           p.nrapolic,
           p.lminsoci,
           p.qtmes_socio,
           p.lmpseleg,
           p.vlcomiss,
           p.pagsegu, 
           p.dtinivigencia, 
           p.dtfimvigencia, 
           p.seqarqu,
           p.qtparcel,
           p.tpadesao,
           p.idadedps,
           p.flginden,
           s.idademin,
           s.idademax,
           s.capitmin,
           s.capitmax,
           c.gbsegmin,
           c.gbsegmax 
      FROM cecred.tbseg_parametros_prst p, 
           cecred.tbseg_param_prst_cap_seg s, 
           cecred.tbseg_param_prst_tax_cob c
     WHERE p.idseqpar = s.idseqpar
       AND p.idseqpar = c.idseqpar
       AND p.tppessoa = 2
     ORDER BY p.cdcooper;

BEGIN
  
  FOR rw_parametros IN cr_parametros LOOP
    
    UPDATE cecred.tbseg_parametros_prst t
       SET t.nrapolic = '77001189',
           t.lminsoci = 0.01,
           t.qtmes_socio = 6,
           t.lmpseleg = 300000,
           t.vlcomiss = 30,
           t.pagsegu = 0.05880000,
           t.dtinivigencia = TO_DATE('01/07/2024','DD/MM/YYYY'),
           t.dtfimvigencia = TO_DATE('30/06/2029','DD/MM/YYYY'),
           t.seqarqu = 1,    
           t.qtparcel = 60,
           t.tpadesao = 1,
           t.idadedps = 0,
           t.flginden = 1
     WHERE t.idseqpar = rw_parametros.idseqpar;
     
    UPDATE cecred.tbseg_param_prst_cap_seg s
       SET s.idademin = 18,
           s.idademax = 65,
           s.capitmin = 0.01,
           s.capitmax = 1000000
     WHERE s.idseqpar = rw_parametros.idseqpar;
     
    UPDATE cecred.tbseg_param_prst_tax_cob c
       SET c.gbsegmin = 0.05586000,
           c.gbsegmax = 0.00294000
     WHERE c.idseqpar = rw_parametros.idseqpar;
     
   COMMIT;  
  END LOOP;
  
  UPDATE cecred.crapprm p
     SET p.dstexprm = 'Chave para ativar a utilização da API Icatu online',
         p.dsvlrprm = 'S'
   WHERE p.nmsistem = 'CRED'
     AND p.cdacesso = 'PROPOSTA_API_ICATU_JURID';

  UPDATE cecred.crapprm p
     SET p.dsvlrprm = '15'
   WHERE p.nmsistem = 'CRED'
     AND p.cdacesso = 'PROPOSTA_API_ICATU_QNTDJ';

  COMMIT;

END;
