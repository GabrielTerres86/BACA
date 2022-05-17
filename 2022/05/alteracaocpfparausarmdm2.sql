begin
update cecred.crapcns a set a.nrdconta =5541  where a.nrcpfcgc=64920194900;
update cecred.crapcns a set a.nrdconta =14690098  where a.nrcpfcgc=21705564000108 and a.nrdgrupo in(10415,10446);
update cecred.crapcns a set a.nrdconta =14690128   where a.nrcpfcgc=21705564000108 and a.nrdgrupo in(10306,10423,10433,30364);
commit;
end;
