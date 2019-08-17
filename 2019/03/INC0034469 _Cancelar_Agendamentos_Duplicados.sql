-- Cancelar agendamentos duplicados.
--Update para atualizar situação dos agendamentos:
UPDATE craplau
   SET craplau.dtdebito = TRUNC(SYSDATE)
      ,craplau.insitlau = 3 --Cancelado
 WHERE craplau.progress_recid =
       (SELECT craplau.progress_recid
          FROM craplau
              ,(SELECT SUBSTR(lau.cdseqtel, 1, 21) nr_liq
                      ,MAX(lau.progress_recid) prg
                      ,COUNT(*) qtde
                  FROM craplau                     lau
                      ,tbdomic_liqtrans_pdv        pdv
                      ,tbdomic_liqtrans_centraliza ctz
                      ,tbdomic_liqtrans_lancto     lct
                      ,tbdomic_liqtrans_arquivo    arq
                 WHERE TRUNC(lau.dtmvtopg) = '08/03/2019'
                   AND lau.cdhistor IN (2444,2443,2442,2450,2453,2478,2484,2485,2486,2487,2488,2489,2490,2491,2492,2445,2546) --crédito
                   AND lau.dtdebito IS NULL
                   AND pdv.nrliquidacao = SUBSTR(lau.cdseqtel, 1, 21)
                   AND ctz.idcentraliza = pdv.idcentraliza
                   AND lct.idlancto = ctz.idlancto
                   AND arq.idarquivo = lct.idarquivo
                   AND NVL(pdv.dserro, 'X') <> 'Agendamento'
                 GROUP BY SUBSTR(lau.cdseqtel, 1, 21)
                HAVING COUNT(*) > 1) teste
         WHERE craplau.progress_recid IN teste.prg);
 
 commit;