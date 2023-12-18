DECLARE

  vr_cdcritica INTEGER;
  vr_dscritica VARCHAR2(4000);
  vr_idanafrd  cecred.craptit.idanafrd%TYPE;

BEGIN

  FOR rw_tit IN (SELECT tit.idanafrd
                       ,CASE
                          WHEN afra_aprovado.idanalise_fraude IS NOT NULL THEN
                           1
                          WHEN afra_reprovado.idanalise_fraude IS NOT NULL THEN
                           2
                          ELSE
                           3
                        END idresultado_antifraude
                   FROM cecred.craptit tit
                   LEFT JOIN pagamento.tbpagto_resultado_antifraude tra
                     ON tra.idanalise_fraude = TIT.IDANAFRD
                   LEFT JOIN cecred.tbgen_analise_fraude afra_aprovado
                     ON afra_aprovado.DTMVTOLT >= tit.DTDPAGTO
                    AND afra_aprovado.CDPRODUTO = 44
                    AND afra_aprovado.CDSTATUS_ANALISE = 3
                    AND afra_aprovado.CDPARECER_ANALISE = 1
                    AND afra_aprovado.idanalise_fraude = tit.idanafrd
                   LEFT JOIN cecred.tbgen_analise_fraude afra_reprovado
                     ON afra_reprovado.DTMVTOLT >= tit.DTDPAGTO
                    AND afra_reprovado.CDPRODUTO = 44
                    AND afra_reprovado.CDSTATUS_ANALISE = 3
                    AND afra_reprovado.CDPARECER_ANALISE = 2
                    AND afra_reprovado.FLGANALISE_MANUAL = 1
                    AND afra_reprovado.idanalise_fraude = tit.idanafrd
                  WHERE tit.cdcooper IN (SELECT cop.cdcooper FROM crapcop cop)
                    AND tit.dtdpagto = to_date('18122023', 'ddmmyyyy')
                    AND TIT.DHRECEBIMENTO_TITULO >= to_date('18122023', 'ddmmyyyy')
                    AND nvl(tit.IDANAFRD, 0) > 0
                    AND tra.idanalise_fraude IS NULL
                 UNION
                 SELECT lau.IDANAFRD
                       ,CASE
                          WHEN afra_aprovado.idanalise_fraude IS NOT NULL THEN
                           1
                          WHEN afra_reprovado.idanalise_fraude IS NOT NULL THEN
                           2
                          ELSE
                           3
                        END idresultado_antifraude
                   FROM cecred.craplau lau
                   LEFT JOIN pagamento.tbpagto_resultado_antifraude tra
                     ON tra.idanalise_fraude = lau.IDANAFRD
                   LEFT JOIN cecred.tbgen_analise_fraude afra_aprovado
                     ON afra_aprovado.DTMVTOLT >= lau.DTMVTOLT
                    AND afra_aprovado.CDPRODUTO = 44
                    AND afra_aprovado.CDSTATUS_ANALISE = 3
                    AND afra_aprovado.CDPARECER_ANALISE = 1
                    AND afra_aprovado.idanalise_fraude = lau.IDANAFRD
                   LEFT JOIN cecred.tbgen_analise_fraude afra_reprovado
                     ON afra_reprovado.DTMVTOLT >= lau.DTMVTOLT
                    AND afra_reprovado.CDPRODUTO = 44
                    AND afra_reprovado.CDSTATUS_ANALISE = 3
                    AND afra_reprovado.CDPARECER_ANALISE = 2
                    AND afra_reprovado.FLGANALISE_MANUAL = 1
                    AND afra_reprovado.idanalise_fraude = lau.IDANAFRD
                  WHERE lau.cdcooper IN (SELECT cop.cdcooper FROM crapcop cop)
                    AND lau.DTMVTOLT = to_date('18122023', 'ddmmyyyy')
                    AND nvl(lau.IDANAFRD, 0) > 0
                    AND tra.idanalise_fraude IS NULL
                    AND length(TRIM(lau.dscodbar)) = 44) LOOP
  
    vr_cdcritica := NULL;
    vr_dscritica := NULL;
    vr_idanafrd  := rw_tit.idanafrd;
  
    IF rw_tit.idresultado_antifraude = 1 THEN
    
      PAGAMENTO.aprovarAntifraudeBoleto(pr_idanalise_fraude => vr_idanafrd
                                       ,pr_cdcritica        => vr_cdcritica
                                       ,pr_dscritica        => vr_dscritica);
    
      IF NVL(vr_cdcritica, 0) <> 0 OR TRIM(vr_dscritica) IS NOT NULL THEN
        raise_application_error(-20001
                               ,'Aprovar antifraude:(' || vr_idanafrd || ')' ||
                                NVL(vr_cdcritica, 0) || '-' || TRIM(vr_dscritica));
      END IF;
    
    ELSIF rw_tit.idresultado_antifraude = 2 THEN
    
      cecred.afra0001.pc_estornar_Titulo_analise(pr_idanalis => vr_idanafrd
                                                ,pr_dtmvtolt => trunc(SYSDATE)
                                                ,pr_inproces => 1
                                                ,pr_cdcritic => vr_cdcritica
                                                ,pr_dscritic => vr_dscritica);
    
      IF NVL(vr_cdcritica, 0) <> 0 OR TRIM(vr_dscritica) IS NOT NULL THEN
        raise_application_error(-20001
                               ,'Reprovar antifraude:(' || vr_idanafrd || ')' ||
                                NVL(vr_cdcritica, 0) || '-' || TRIM(vr_dscritica));
      END IF;
    
    END IF;
  
    COMMIT;
  
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    sistema.excecaoInterna(pr_cdcooper => 3, pr_compleme => 'INC0307260:(' || vr_idanafrd || ')');
    ROLLBACK;
    RAISE;
END;
