BEGIN
      UPDATE cecred.craptar tar SET tar.cdsubgru = 19 where cdtarifa = 212;
      COMMIT;
END;