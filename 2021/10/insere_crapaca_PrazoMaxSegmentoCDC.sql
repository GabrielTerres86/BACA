--
-- ver parcdc.js manterRotinaPrazosSegmento
--
DECLARE
  vr_nrseqaca      crapaca.nrseqaca%TYPE;
BEGIN
  DELETE crapaca
  WHERE nmdeacao in ( 'INCLUIR_PRAZO_MAX_SEGMENTO_CDC'
                     ,'ALTERAR_PRAZO_MAX_SEGMENTO_CDC'
                     ,'EXCLUIR_PRAZO_MAX_SEGMENTO_CDC'
                     ,'OBTER_PRAZO_MAX_SEGMENTO_CDC'
                    );

  SELECT  max(nrseqaca) + 1
  INTO    vr_nrseqaca
  FROM    crapaca;

  insert into crapaca ( nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr
                      )
              values  ( vr_nrseqaca
                       ,'INCLUIR_PRAZO_MAX_SEGMENTO_CDC'
                       ,'CREDITO'
                       ,'incluirPrazoMaxSegmentoCDC'
                       ,'pr_cdcooper,pr_cdsegmento,pr_nrinitempo_modelo,pr_nrfimtempo_modelo,pr_qtmaxpar'
                       ,1345
                      );

  vr_nrseqaca := vr_nrseqaca + 1;
  insert into crapaca ( nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr
                      )
              values  ( vr_nrseqaca
                       ,'ALTERAR_PRAZO_MAX_SEGMENTO_CDC'
                       ,NULL
                       ,'CREDITO.alterarPrazoMaxSegmentoCDC'
                       ,'pr_cdcooper,pr_cdsegmento,pr_nrseqprazo,pr_nrinitempo_modelo,pr_nrfimtempo_modelo,pr_qtmaxpar'
                       ,1345
                      );

  vr_nrseqaca := vr_nrseqaca + 1;
  insert into crapaca ( nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr
                      )
              values  ( vr_nrseqaca
                       ,'EXCLUIR_PRAZO_MAX_SEGMENTO_CDC'
                       ,NULL
                       ,'CREDITO.excluirPrazoMaxSegmentoCDC'
                       ,'pr_cdcooper,pr_cdsegmento,pr_nrseqprazo'
                       ,1345
                      );

  vr_nrseqaca := vr_nrseqaca + 1;
  insert into crapaca ( nrseqaca
                       ,nmdeacao
                       ,nmpackag
                       ,nmproced
                       ,lstparam
                       ,nrseqrdr
                      )
              values  ( vr_nrseqaca
                       ,'OBTER_PRAZO_MAX_SEGMENTO_CDC'
                       ,NULL
                       ,'CREDITO.obterPrazoMaxSegmentoCDC'
                       ,'pr_cdcooper,pr_cdsegmento,pr_nrseqprazo'
                       ,1345
                      );

  COMMIT;
END;
