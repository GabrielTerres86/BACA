begin
  delete crapbpr where crapbpr.cdcooper = 5 and progress_recid = 5637091;
  delete crapbpr where crapbpr.cdcooper = 1 and progress_recid = 5680690;

  commit;
end;