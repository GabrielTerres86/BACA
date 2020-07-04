--INC0051937 -> Cancelar agendamento de recarga, pois já foram efetivadas
update tbrecarga_operacao topr set topr.insit_operacao = 4 where topr.progress_recid = 1356202;
update tbrecarga_operacao topr set topr.insit_operacao = 4 where topr.progress_recid = 1356223;

Commit;
