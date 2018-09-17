<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO     	: Jonata Cardoso (RKAM)        
 * DATA CRIAÇÃO : Julho/2014
 * OBJETIVO     : Cabecalho para a tela Conaut
  */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;">
	<table width="99%">
		<tr>		
			<td> 	
				<label for="cdtipcad"><? echo utf8ToHtml('Cadastro') ?></label>	
				<select class='campo' id='cdtipcad' name='cdtipcad'>
					
					<? if ($glbvars["cdcooper"] == 3) { ?>
						<option value='B'><? echo utf8ToHtml('Cadastro de Bir&ocirc;s') ?></option>
						<option value='M'>Cadastro de Modalidade</option>
					<? } ?>
					<option value='P'><? echo utf8ToHtml('Parametriza&ccedil;&atilde;o da Proposta') ?></option>
					<option value='T'>Tempo de Retorno de Consultas </option>
					<option value='R'>Reaproveitamento de Consultas</option>
					<option value='C'><? echo utf8ToHtml('Conting&ecirc;ncia') ?></option>
					
				</select>
			</td>
		</tr>
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o') ?></label>	
				<select class='campo' id='cddopcao' name='cddopcao'>
					<option value='C'><? echo utf8ToHtml('C - Consulta') ?></option>
					<option value='A'><? echo utf8ToHtml('A - Altera&ccedil;&atilde;o') ?></option>
					<option value='I'><? echo utf8ToHtml('I - Inclus&atilde;o') ?></option>
					<option value='E'><? echo utf8ToHtml('E - Exclus&atilde;o') ?></option>
				</select>
				<a href="#" class="botao" id="btOK" name="btnOK" onClick ="liberaCampos();" style = "text-align:right;">OK</a>
			</td>
		</tr>
	</table>
</form>