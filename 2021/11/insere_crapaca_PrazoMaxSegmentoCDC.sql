--
-- ver parcdc.js manterRotinaPrazosSegmento
--
DECLARE
BEGIN
  DELETE crapaca
  WHERE nmdeacao in ( 'INCLUIR_PRAZO_MAX_SEGMENTO_CDC'
                     ,'ALTERAR_PRAZO_MAX_SEGMENTO_CDC'
                     ,'EXCLUIR_PRAZO_MAX_SEGMENTO_CDC'
                     ,'OBTER_PRAZO_MAX_SEGMENTO_CDC'
                    );

  insert into crapaca ( nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr
                      )
              values  ( 'INCLUIR_PRAZO_MAX_SEGMENTO_CDC'
                       ,'CREDITO'
                       ,'incluirPrazoMaxSegmentoCDC'
                       ,'pr_cdcooper,pr_cdsegmento,pr_nrinitempo_modelo,pr_nrfimtempo_modelo,pr_qtmaxpar'
                       ,1345
                      );

  insert into crapaca ( nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr
                      )
              values  ( 'ALTERAR_PRAZO_MAX_SEGMENTO_CDC'
                       ,NULL
                       ,'CREDITO.alterarPrazoMaxSegmentoCDC'
                       ,'pr_cdcooper,pr_cdsegmento,pr_nrseqprazo,pr_nrinitempo_modelo,pr_nrfimtempo_modelo,pr_qtmaxpar'
                       ,1345
                      );

  insert into crapaca ( nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr
                      )
              values  ( 'EXCLUIR_PRAZO_MAX_SEGMENTO_CDC'
                       ,NULL
                       ,'CREDITO.excluirPrazoMaxSegmentoCDC'
                       ,'pr_cdcooper,pr_cdsegmento,pr_nrseqprazo'
                       ,1345
                      );

  insert into crapaca ( nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr
                      )
              values  ( 'OBTER_PRAZO_MAX_SEGMENTO_CDC'
                       ,NULL
                       ,'CREDITO.obterPrazoMaxSegmentoCDC'
                       ,'pr_cdcooper,pr_cdsegmento,pr_nrseqprazo'
                       ,1345
                      );

  COMMIT;
END;
