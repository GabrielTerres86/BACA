-- Adicao de convenios a lista de declaracao --

update gnconve set flgdecla = 1 where cdconven in (22,32,46,47,50,55,58,64,67,69);
commit;