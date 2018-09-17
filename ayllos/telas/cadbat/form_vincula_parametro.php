<?
/*!
 * FONTE        : form_vincula_parametro.php
 * CRIAÇÃO      : Tiago Machado         
 * DATA CRIAÇÃO : 20/04/2013
 * OBJETIVO     : Form de vinculacao de parametro
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<div id="divDadosParametro" name="divDadosParametro">
	<form id="frmDadosParametro" name="frmDadosParametro" class="formulario" onSubmit="return false;" style="display:none">
		<fieldset width="100%">
			<legend>Dados do Parametro</legend>
			<table width="100%">
				<tr>		
					<td>
						<label for="cdpartar"><? echo utf8ToHtml('Parametro:') ?></label>
						<input type="text" id="cdpartar" name="cdpartar" value="<? echo $cdpartar == 0 ? '' : $cdpartar ?>" />	
						<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
						<input type="text" name="nmpartar" id="nmpartar"  value="<? echo $nmpartar; ?>" />				
					</td>
				</tr>		
				<tr>		
					<td>
						<label for="tpdedado"><? echo utf8ToHtml('Tipo de dado:') ?></label>						
						<select id="tpdedado" name="tpdedado" value="<? echo $tpdedado == 0 ? '' : $tpdedado ?>" >
							<option value="0">NENHUM</option>
							<option value="1">1 - INTEIRO</option>
							<option value="2">2 - TEXTO</option>
							<option value="3">3 - VALOR</option>
							<option value="4">4 - DATA</option>
						</select>
					</td>			
				</tr>				
			</table>
		</fieldset>
	</form>
</div>