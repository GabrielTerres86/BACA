<? 
/*!
 * FONTE        : formulario_faturamento.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Forumlário de dados de Faturamento para alteracao
 *
 * ALTERACOES   : 001: [05/09/2012] Mudar para layout padrao (Gabriel) 
 */	
?>	
<div id="frmFaturamento">

	<form name="frmFat" id="frmFat" class="formulario" >
	
		<input name="nrposext" id="nrposext" type="hidden" value="" />
	
		<label for="mesftbru"><? echo utf8ToHtml(Mês);?></label>
		<input name="mesftbru" id="mesftbru" type="text" value="" />
		<br />
		
		<label for="anoftbru">Ano:</label>
		<input name="anoftbru" id="anoftbru" type="text" value="" />
		<br />
		
		<label for="vlrftbru">Faturamento :</label>
		<input name="vlrftbru" id="vlrftbru" type="text" value="" />
		<br style="clear:both;"/>			
	</form>
		
	<div id="divBotoes">
		<a href="#" class="botao" id="btVoltar"    onClick="controlaOperacaoFat('BR'); return false;">Cancelar</a>
		<a href="#" class="botao" name="btSalvar" id="btSalvar" >Concluir</a>
	</div>
	
</div>

<script>

	highlightObjFocus($('#frmFaturamento'));

</script>