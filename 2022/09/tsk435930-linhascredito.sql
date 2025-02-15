BEGIN
  
UPDATE CECRED.CRAPLCR
   SET tpcuspr = 1
 WHERE flgsegpr = 1
   AND (cdcooper, cdlcremp) in ((9, 1),
                                (9, 2),
                                (9, 3),
                                (9, 4),
                                (9, 5),
                                (9, 6),
                                (9, 7),
                                (9, 59),
                                (9, 60),
                                (9, 61),
                                (9, 62),
                                (9, 528),
                                (9, 1106),
                                (9, 2106),
                                (9, 2179),
                                (9, 2600),
                                (9, 2610),
                                (9, 2700),
                                (9, 6901),
                                (9, 10000),
                                (9, 11000),
                                (9, 11890),
                                (11, 1),
                                (11, 2),
                                (11, 3),
                                (11, 4),
                                (11, 5),
                                (11, 6),
                                (11, 7),
                                (11, 27),
                                (11, 78),
                                (11, 180),
                                (11, 181),
                                (11, 182),
                                (11, 183),
                                (11, 184),
                                (11, 185),
                                (11, 261),
                                (11, 286),
                                (11, 334),
                                (11, 371),
                                (11, 373),
                                (11, 389),
                                (11, 2600),
                                (11, 2610),
                                (11, 2700),
                                (11, 6901),
                                (11, 7004),
                                (11, 7005),
                                (11, 10000),
                                (11, 11000),
                                (11, 11890),
                                (13, 1),
                                (13, 2),
                                (13, 3),
                                (13, 4),
                                (13, 5),
                                (13, 6),
                                (13, 7),
                                (13, 13),
                                (13, 14),
                                (13, 15),
                                (13, 58),
                                (13, 63),
                                (13, 64),
                                (13, 65),
                                (13, 70),
                                (13, 71),
                                (13, 78),
                                (13, 79),
                                (13, 82),
                                (13, 83),
                                (13, 84),
                                (13, 85),
                                (13, 86),
                                (13, 87),
                                (13, 88),
                                (13, 89),
                                (13, 141),
                                (13, 170),
                                (13, 195),
                                (13, 196),
                                (13, 204),
                                (13, 205),
                                (13, 206),
                                (13, 207),
                                (13, 208),
                                (13, 209),
                                (13, 210),
                                (13, 211),
                                (13, 212),
                                (13, 213),
                                (13, 215),
                                (13, 216),
                                (13, 217),
                                (13, 218),
                                (13, 219),
                                (13, 220),
                                (13, 221),
                                (13, 222),
                                (13, 223),
                                (13, 224),
                                (13, 225),
                                (13, 226),
                                (13, 227),
                                (13, 228),
                                (13, 229),
                                (13, 230),
                                (13, 231),
                                (13, 232),
                                (13, 233),
                                (13, 234),
                                (13, 235),
                                (13, 236),
                                (13, 238),
                                (13, 239),
                                (13, 240),
                                (13, 241),
                                (13, 242),
                                (13, 250),
                                (13, 251),
                                (13, 252),
                                (13, 253),
                                (13, 257),
                                (13, 272),
                                (13, 273),
                                (13, 279),
                                (13, 280),
                                (13, 281),
                                (13, 335),
                                (13, 379),
                                (13, 392),
                                (13, 393),
                                (13, 394),
                                (13, 395),
                                (13, 396),
                                (13, 397),
                                (13, 398),
                                (13, 399),
                                (13, 401),
                                (13, 413),
                                (13, 414),
                                (13, 1106),
                                (13, 2106),
                                (13, 2600),
                                (13, 2610),
                                (13, 2700),
                                (13, 6901),
                                (13, 10000),
                                (13, 11000),
                                (13, 11890));
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
/
