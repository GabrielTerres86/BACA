begin
  delete crapbpr where crapbpr.cdcooper = 5 and progress_recid = 5684663;
  delete crapbpr where crapbpr.cdcooper = 5 and progress_recid = 5684664;
  delete crapbpr where crapbpr.cdcooper = 5 and progress_recid = 5684924;
  delete crapbpr where crapbpr.cdcooper = 5 and progress_recid = 5684925;

  commit;
end;