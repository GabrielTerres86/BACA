UPDATE TBCC_LANCAMENTOS_PENDENTES
SET IDSITUACAO = 'M',
DSCRITICA = 'INC0078651 Ajustado manualmente, estava contabilizando erro no extrato do cooperado, a transação original foi creditada/debitada normalmente.'
WHERE IDSITUACAO = 'E'
AND DSCRITICA = 'Erro ao lançar movimento na conta: 092 - Lancamento ja existe pc_gerar_lancamento_conta - ORA-00001: restrição exclusiva (CECRED.CRAPLCM##CRAPLCM1) violada)'
AND E.IDSEQ_LANCAMENTO IN (608089,
                            2546700,
                            2705855,
                            1429384,
                            1429401,
                            1429407,
                            1429392,
                            2495204,
                            1923973,
                            1923980,
                            1281584,
                            1281583,
                            1281582,
                            1281017,
                            1281020,
                            1281384,
                            1281022,
                            1281381,
                            1281586,
                            1281021,
                            1281383,
                            1281382,
                            1281380,
                            1281585,
                            1281019,
                            1281385);
COMMIT;