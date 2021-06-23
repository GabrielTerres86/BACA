update craptel tel set tel.cdopptel = replace(tel.cdopptel, ' ', '') where tel.nmdatela = 'UPPGTO';

commit;