<?
/*
 * FONTE        : form_importacao.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : Agosto/2011
 * OBJETIVO     : Cabeçalho para a tela CADDNE
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<form id="frmImportacao" name="frmImportacao" class="formulario" style="display:none;" onSubmit="executa_opcao(); return false;">	
	
	<label id="dsimport"> Selecione os estados que deseja importar: </label>
	<br style="clear:both" />
	<?php 
		$estados = retornaUFs(); 
	?>
	<table id="estados">
		<?php for($i=0;$i < 7; $i++) { ?>
		<tr>
			<td><input type="checkbox" id="<?php echo $estados[$i]["SIGLA"] ?>" value="<?php echo $estados[$i]["SIGLA"] ?>"/></td>
			<td><label for="<?php echo $estados[$i]["SIGLA"] ?>"><?php echo $estados[$i]["NOME"] ?></label></td>
			<td><input type="checkbox" id="<?php echo $estados[$i + 7]["SIGLA"] ?>" value="<?php echo $estados[$i + 7]["SIGLA"] ?>"/></td>
			<td><label for="<?php echo $estados[$i + 7]["SIGLA"] ?>"><?php echo $estados[$i + 7]["NOME"] ?></label></td>
			<td><input type="checkbox" id="<?php echo $estados[$i + 14]["SIGLA"] ?>" value="<?php echo $estados[$i + 14]["SIGLA"] ?>"/></td>
			<td><label for="<?php echo $estados[$i + 14]["SIGLA"] ?>"><?php echo $estados[$i + 14]["NOME"] ?></label></td>
			<?php if ($estados[$i + 21]["SIGLA"] != "") { ?>
			<td><input type="checkbox" id="<?php echo $estados[$i + 21]["SIGLA"] ?>" value="<?php echo $estados[$i + 21]["SIGLA"] ?>"/></td>
			<td><label for="<?php echo $estados[$i + 21]["SIGLA"] ?>"><?php echo $estados[$i + 21]["NOME"] ?></label></td>
			<?php } ?>
		<tr>
		<?php } ?>
		<tr>
			<td><input type="checkbox" id="<?php echo 'UNID_OPER' ?>" value="<?php echo 'UNID_OPER' ?>"/></td>
			<td><label for="<?php echo 'UNID_OPER' ?>"><?php echo 'Unid.Oper' ?></label></td>
			<td><input type="checkbox" id="<?php echo 'GRANDE_USUARIO' ?>" value="<?php echo 'GRANDE_USUARIO' ?>"/></td>
			<td><label for="<?php echo 'GRANDE_USUARIO' ?>"><?php echo 'Grandes Usuários' ?></label></td>
			<td><input type="checkbox" id="<?php echo 'CPC' ?>" value="<?php echo 'CPC' ?>"/></td>
			<td><label for="<?php echo 'CPC' ?>"><?php echo 'Cx.Postal Comunitária' ?></label></td>
		</tr>
	</table>
	<input type="image" id="btTodasEnd" src="<? echo $UrlImagens; ?>botoes/todos.gif" onClick="marcaTodosUfs();return false;" />
	<input type="image" id="btLimparEnd" src="<? echo $UrlImagens; ?>botoes/limpar.gif" onClick="desmarcaTodosUfs();return false;" style="margin-left:10px;" />
	<input type="hidden" id='estados' name='estados'></input>
</form>