begin
   delete cecred.tbseg_req_nrproposta_pj pj where pj.cdcooper = 11 and pj.cdstatus = 1;
   commit;
end;   
