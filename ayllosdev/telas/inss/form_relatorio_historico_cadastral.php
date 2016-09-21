<?
/*****************************************************************************************************
  Fonte        : form_relatorio_historico_cadastral.php
  Criação      : Adriano
  Data criação : Março/2015
  Objetivo     : Mostra o form para solicitação do relatório de historico cadastral
  --------------
  Alterações   :
  --------------
 *****************************************************************************************************/ 
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmRelatorioHistoricoCadastral" name="frmRelatorioHistoricoCadastral" class="formulario" style="display:none;">	
	
		
	<fieldset id="fsetRelatorioHistoricoCadastral" name="fsetRelatorioHistoricoCadastral" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend> Hist&oacute;rico Cadastral</legend>
				
		<label for="nrrecben">NB:</label>
		<input id="nrrecben" name="nrrecben" type="text"></input>
				
		<br />	
						
	</fieldset>		
	
</form>

<div id="divBotoesRelatorioHistoricoCadastral" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar">Voltar</a>
	<a href="#" class="botao" id="btConcluir">Concluir</a> 
	
</div>