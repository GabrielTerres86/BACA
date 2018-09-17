<?php
/***************************************************************************************************
  Fonte        : form_relatorio_beneficios_pagos.php
  Criação      : Adriano									   Última alteração: 20/03/2015
  Data criação : Junho/2013
  Objetivo     : Mostra o form para solicitação do relatório de benefícios pagos
  --------------
	Alterações   : 20/03/2015 - Ajuste para atender ao novo processo de chamada do relatório (Adriano).
					03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
  --------------
 **************************************************************************************************/ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmRelatorioBeneficiosPagos" name="frmRelatorioBeneficiosPagos" class="formulario" style="display:none;">	
	
		
	<fieldset id="fsetRelatorioBeneficiosPagos" name="fsetRelatorioBeneficiosPagos" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend> Benef&iacute;cios pagos</legend>
		
		<label for="cdagenci">PA:</label>
		<input id="cdagenci" name="cdagenci" type="text" ></input>
		<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaRelatorioPagos(5); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			
		<br />
		
		<label for="nrrecben">NB:</label>
		<input id="nrrecben" name="nrrecben" type="text"></input>
				
		<br />
		
		<label for="dtinirec">Data inicial de pagamento:</label>
		<input id="dtinirec" name="dtinirec" type="text" ></input>
		
		<br />
		
		<label for="dtfinrec">Data final de pagamento:</label>
		<input id="dtfinrec" name="dtfinrec" type="text" ></input>
		
		<br />
				
	</fieldset>		
	
</form>

<div id="divTabelaRelatorios" style="display:none;" >

</div>

<div id="divBotoesRelatorioBeneficiosPagos" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar">Voltar</a>
	<a href="#" class="botao" id="btGerados">Visualizar</a>
	<a href="#" class="botao" id="btConcluir">Solicitar</a>
	
</div>