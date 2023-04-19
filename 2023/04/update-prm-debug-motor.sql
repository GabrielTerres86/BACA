begin

update crapprm set CDCOOPER = 11, DSVLRPRM = 'S' where cdacesso = 'DEBUG_ANALISE_LIMITE' and cdcooper = 16;

commit;   

end;