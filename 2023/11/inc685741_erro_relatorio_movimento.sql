BEGIN
  UPDATE CECRED.crapret ret
     SET ret.vltarass = 0
   WHERE ret.rowid IN ('AABDewAAJAAFFQ+AAR', 'AABDewAAJAAFFQ+AAS', 'AABDewAAJAAFFkSAAW');
   COMMIT;
END;
