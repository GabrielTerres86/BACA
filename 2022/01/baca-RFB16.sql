begin
update gncvuni set gncvuni.flgproce = 1 where gncvuni.flgproce = 0;
commit;

end;