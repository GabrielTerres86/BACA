begin
  delete crapbpr where crapbpr.cdcooper = 5 and progress_recid = 5650141;
  delete crapbpr where crapbpr.cdcooper = 5 and progress_recid = 5650142;

  commit;
end;