update gnconve a
set a.dsagercb = substr(a.dsagercb, 1, length(a.dsagercb)-1);
commit;
