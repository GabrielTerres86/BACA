<?
/*!

 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 22/09/2017
 * OBJETIVO     : Cabeçalho para a tela CADMAT
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" alt="Informe a opcao desejada (C, D, I ou R).">
		<? if ($crm_nrdconta > 0 || $crm_inacesso == 0){ ?>
			<option value="C"> C - Consultar os dados cadastrais da matricula do cooperado.</option> 		
			<option value="D"> D - Desvincular o numero da matricula de uma conta duplicada da conta mae (conta origem da duplicacao).</option>			
			<option value="R"> R - Imprimir a ficha de matricula do cooperado</option>
		<?}else{?>
			<option value="I"> I - Incluir os dados cadastrais do novo cooperado.</option>
		<?}?>
	</select>
	<a href="#" class="botao" id="btnOK" name="btnOK" style="text-align:right;">OK</a>
	
	<br />
	
	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" alt="Informe o numero da conta do cooperado." />
	<a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
	<label for="inpessoa"></label>	
	<input name="inpessoa" id="pessoaFi" type="radio" class="radio" value="1" style="margin: 7px 3px 0px 3px !important; height: 16px !important;" />
	<label for="pessoaFi" class="radio">F&iacute;sica</label>
	<input name="inpessoa" id="pessoaJu" type="radio" class="radio" value="2" style="margin: 7px 3px 0px 3px !important; height: 16px !important;"/>
	<label for="pessoaJu" class="radio">Jur&iacute;dica</label>

	<br style="clear:both" />	
</form>