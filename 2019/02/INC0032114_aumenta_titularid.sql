-- Aumenta o tamanho da coluna titularid de 1 para 2 d�gitos
alter table CECRED.DISPOSITIVOMOBILE modify titularid NUMBER(2);
alter table CECRED.ESTATISTICAMOBILE modify titularid NUMBER(2);
