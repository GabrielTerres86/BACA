UPDATE CECRED.CRAPTEL s
SET s.cdopptel = s.cdopptel || ',X',
    s.lsopptel = s.lsopptel || ',CONTROLE QUALIFICACAO'
WHERE s.nmdatela = 'ATENDA' and s.nmrotina = 'PRESTACOES';

COMMIT;