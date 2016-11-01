<? 
/*!
 * FONTE        : tabela_altera.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : 24/06/2011
 * OBJETIVO     : Tabela que apresenda as alteracoes da conta informada na tela ALTERA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [27/03/2012] Rogérius Militão (DB1) : novo layout padrão, alterado "width" do campo dsaltera;
 */	
?>
<? $search  = array('.','-'); 
?>

<form class="formulario" onSubmit="return false;">
<fieldset>
<legend>Alterações Cadastrais</legend>
<div class="divRegistros">
	<?
	foreach($registros as $altera) {
		$dtaltera = getByTagName($altera->tags,'dtaltera');
		$tpaltera = getByTagName($altera->tags,'tpaltera');
		$dsaltera = getByTagName($altera->tags,'dsaltera');
		$nmoperad = getByTagName($altera->tags,'nmoperad');
	?>
		<table>
			<tr>
				<td align="left"  style="padding-bottom: 2px; padding-top: 4px;"> 
					<label for="dtaltera" class="txtNormalBold">Data:</label>
					<input id ="dtaltera" name="dtaltera" type="text" value="<? echo $dtaltera ?>">
					<label for="tpaltera" class="txtNormalBold">Tipo:</label>
					<input id ="tpaltera" name="tpaltera" type="text" value="<? echo $tpaltera ?>">
					<label for="nmoperad" class="txtNormalBold">Operador:</label>
					<input id ="nmoperad" name="nmoperad" type="text" value="<? echo $nmoperad ?>">
				</td>
			</tr>
			<tr>
				<td align="left"  style="padding-bottom: 2px; padding-top: 4px;"> 
					<label for="dsaltera" class="txtNormalBold">Dados Alterados/Incluidos:</label>
				</td>
			</tr>		
			<tr style="border-bottom: 2px solid #969FA9; background-color: #F4F3F0;">
				<td align="left" style="padding-bottom: 2px;">
					<textarea name="dsaltera" id="dsaltera" style="overflow-y: scroll; overflow-x: hidden; width: 685px; height: 100px;" readonly><?php echo trim($dsaltera) ?></textarea>
				</td>
			</tr>
			<tr>
				<td height="1px"><hr></td>
			</tr>
		</table>
	<? } ?>
</div>
</fieldset>
</form>