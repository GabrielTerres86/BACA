begin
update crapseg set CDSITSEG = 1, dtcancel = '', cdopeexc = 0, cdageexc = 0, dtinsexc = '',cdopecnl = '' where PROGRESS_RECID = 934783;
update tbseg_prestamista set tpregist = 3 where idseqtra = 213341;
commit;
end;