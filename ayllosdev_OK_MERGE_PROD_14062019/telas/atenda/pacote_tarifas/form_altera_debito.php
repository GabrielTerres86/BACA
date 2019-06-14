<?
/*!
 * FONTE        : form_consulta_pacote.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 18/03/2016
 * OBJETIVO     : Tela do formulario de detalhamento de tarifas
 */	 

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	
?>

<form name="frmAlteraDebito" id="frmAlteraDebito" class="formulario" >
	<fieldset>
		<legend>Alterar D&eacute;bito</legend>
		
		<label for="dtdiadebito">Dia do d&eacute;bito:</label>
		<select name="dtdiadebito" style="text-align: right;" id="dtdiadebito">
			<option value="1">01</option>
			<option value="5">05</option>
			<option value="10">10</option>
			<option value="20">20</option>
		</select>
		
	</fieldset>
</form>	

<div id="divBotoes">
	<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btVoltar" onClick="acessaOpcaoAba(1,0,0);return false;">Voltar</a>
	<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:70px; " id="btConfirmar" onClick="alteraDebito(<?echo $nrdconta;?>);return false;">Confirmar</a>
</div>
<script language="JavaScript">

</script>