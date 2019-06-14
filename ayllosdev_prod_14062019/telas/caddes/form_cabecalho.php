<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Augusto - Supero
 * DATA CRIAÇÃO : 17/10/18
 * OBJETIVO     : Cabeçalho para a tela SOLPOR
 * -------------- 
 * ALTERAÇÕES   : 
 * 
 * --------------
 */
 
$isPlataformaAPI = ((isset($_POST['isPlataformaAPI'])) ? 1 : 0);

?>

<div id="divCab">
	<form id="frmCab" name="frmCab" class="formulario cabecalho">

		<input id="registro" name="registro" type="hidden" value=""  />
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		<input type="hidden" name="isPlataformaAPI" id="isPlataformaAPI" value="<?php echo $isPlataformaAPI; ?>">
			
		<label for="cddopcao" style="width: 68px;"><? echo utf8ToHtml('Opção:') ?></label>
		<select id="cddopcao" class="campo" name="cddopcao" style="width: 530px;">
			<option value="C" <? echo $cddopcao == 'C' ? 'selected' : '' ?>> C - <?php echo utf8ToHtml('Consultar um desenvolvedor'); ?></option>
			<option value="I" <? echo $cddopcao == 'I' ? 'selected' : '' ?>> I - <?php echo utf8ToHtml('Incluir um novo desenvolvedor'); ?></option>
			<option value="A" <? echo $cddopcao == 'A' ? 'selected' : '' ?>> A - <?php echo utf8ToHtml('Alterar um desenvolvedor'); ?></option>
			<option value="E" <? echo $cddopcao == 'E' ? 'selected' : '' ?>> E - <?php echo utf8ToHtml('Excluir um desenvolvedor'); ?></option>
		</select>	
		<a href="#" class="botao" id="btnOKCab" onClick="carregaOpcaoCabecalhoSelecionada(); return false;">OK</a>
			
		<br style="clear:both" />	
		
	</form>
</div>