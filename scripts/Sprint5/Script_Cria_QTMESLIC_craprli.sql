alter table cecred.craprli
add column qtmeslic number(5) not null default 0;
-- Obs.: Default 0 para seguir mesmo padrão do campo qtdialiq
 
Comment on column cecred.craprli.qtmeslic 'Quantidade de Meses do novo limite após o cancelamento' ;
 