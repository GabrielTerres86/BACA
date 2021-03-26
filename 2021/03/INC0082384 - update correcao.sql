update tbcc_lancamentos_pendentes t 
set idsituacao = 'M', dscritica = 'INC0082384 ajustado para corrigir extrato da conta'
where t.idseq_lancamento in ('4353668','4822438','4792631','4822439','4792633','4792630');

commit;
