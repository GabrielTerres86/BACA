BEGIN

  UPDATE cecred.tbcapt_custodia_aplicacao aplupt 
     SET aplupt.QTCOTAS = aplupt.vlregistro / aplupt.VLPRECO_UNITARIO
   WHERE EXISTS (SELECT 0
                   FROM cecred.tbcapt_custodia_arquivo arq
                  INNER JOIN cecred.tbcapt_custodia_conteudo_arq cnt
                     ON cnt.idarquivo = arq.idarquivo
                  INNER JOIN cecred.tbcapt_custodia_aplicacao apl
                     ON apl.idaplicacao = cnt.idaplicacao
                  INNER JOIN cecred.tbcapt_custodia_lanctos lct
                     ON lct.idaplicacao = apl.idaplicacao
                    AND lct.idlancamento = cnt.idlancamento
                  WHERE arq.dtregistro IN ('25/11/2022', '05/07/2023', '14/09/2023', '15/09/2023') 
                    AND TRUNC(arq.dtcriacao) >= '10/04/2024' 
                    AND arq.idtipo_operacao = 'E'
                    AND cnt.IDTIPO_LINHA = 'L'
                    AND lct.idsituacao = 9
                    AND aplupt.idaplicacao = apl.idaplicacao);
  
  COMMIT; 
  
  UPDATE cecred.tbcapt_custodia_lanctos lctupt
     SET lctupt.QTCOTAS = lctupt.vlregistro / lctupt.VLPRECO_UNITARIO,
         lctupt.IDSITUACAO = 2
   WHERE EXISTS (SELECT 0
                   FROM cecred.tbcapt_custodia_arquivo arq
                  INNER JOIN cecred.tbcapt_custodia_conteudo_arq cnt
                     ON cnt.idarquivo = arq.idarquivo
                  INNER JOIN cecred.tbcapt_custodia_aplicacao apl
                     ON apl.idaplicacao = cnt.idaplicacao
                  INNER JOIN cecred.tbcapt_custodia_lanctos lct
                     ON lct.idaplicacao = apl.idaplicacao
                    AND lct.idlancamento = cnt.idlancamento
                  WHERE arq.dtregistro IN ('25/11/2022', '05/07/2023', '14/09/2023', '15/09/2023') 
                    AND TRUNC(arq.dtcriacao) >= '10/04/2024' 
                    AND arq.idtipo_operacao = 'E'
                    AND cnt.IDTIPO_LINHA = 'L'
                    AND lct.idsituacao = 9
                    AND lctupt.IDLANCAMENTO = lct.idlancamento
                    AND lctupt.idaplicacao = lct.idaplicacao);                          
                            
  COMMIT;
END;
