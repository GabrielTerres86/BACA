<?php

	//************************************************************************//
	//*** Fonte: exibe_log.php                                             ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Janeiro/2012                 Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Exibir o log do processamento dos arquivos de debito ***//	
	//***                                                                  ***//
	//***                                                                  ***//
	//*** Alterações: 08/02/2012 - Ajustes Pamcar (Adriano).		       ***//
	//***                          									       ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	
	session_start();
	
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica permiss&atilde;o
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X");
		
		
	$dtinicio = $_POST["dtinicio"];
	$dtfim    = $_POST["dtfim"];
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","$(\'#dtinicio\',\'#divLogProcesso\').focus();");';
		exit();
	}
	
	
	// Monta o xml de requisição
	$xmlLogProcesso  = "";
	$xmlLogProcesso .= "<Root>";
	$xmlLogProcesso .= "	<Cabecalho>";
	$xmlLogProcesso .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlLogProcesso .= "		<Proc>busca_log_processamento</Proc>";
	$xmlLogProcesso .= "	</Cabecalho>";
	$xmlLogProcesso .= "	<Dados>";
	$xmlLogProcesso .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlLogProcesso .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlLogProcesso .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlLogProcesso .= "		<dtinicio>".$dtinicio."</dtinicio>";
	$xmlLogProcesso .= "		<dtfim>".$dtfim."</dtfim>";
	$xmlLogProcesso .= "	</Dados>";
	$xmlLogProcesso .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlLogProcesso);
	
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLogProcesso = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLogProcesso->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLogProcesso->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$log_processo = $xmlObjLogProcesso->roottag->tags[0]->tags;	
	
	$log_count = count($log_processo);
	
	if ($log_count == 0)
		exibeErro("N&atilde;o h&aacute registro de log para o per&iacute;odo informado.");
	
	
	
	?>
		
	var strHTML = "";
		
	strHTML +='<div class="divLogProcessamento">';
	strHTML += '	<fieldset>';
	strHTML += '	<legend align="center"><b>LOG DO PROCESSAMENTO</b></legend>';
		
	strHTML += '<div class="divRegistros">';
		
	strHTML += '		<table>';
	strHTML += '			<thead>';
	strHTML += '				<tr>';
	strHTML += '                    <th><? echo utf8ToHtml('Arquivo'); ?></th>';
	strHTML += '					<th><? echo utf8ToHtml('Status');  ?></th>';
	strHTML += '					<th><? echo utf8ToHtml('Processamento');  ?></th>';
	strHTML += '				</tr>';
	strHTML += '			</thead>';
	strHTML += '			<tbody>';
	
	<?php
		
	for ($i = 0; $i < $log_count; $i++){
	
		$nmarquiv = getByTagName($log_processo[$i]->tags,"NMARQUIV");
		$dsstatus = getByTagName($log_processo[$i]->tags,"DSSTATUS");
		$dtproces = getByTagName($log_processo[$i]->tags,"DTPROCES");
			
		?>
		strHTML += '<tr id="trArquivosProcessados<?php echo $i; ?>" style="cursor: pointer;">';
		strHTML += '	<td><?php echo $nmarquiv; ?>';
		strHTML += '	</td>';
		strHTML += '	<td><?php echo $dsstatus; ?>';
		strHTML += '	</td>';
		strHTML += '	<td><?php echo $dtproces; ?>';
		strHTML += '	</td>';	
		strHTML += '</tr>';
		<?php
	}
		
	?>
		
	strHTML += '			</tbody>';
	strHTML += '		</table>';
	strHTML += '</div>';
	strHTML += '	</fieldset>';
	strHTML += '</div>';
		
		
	$("#divLog").html(strHTML);
	formataTabelaLog();
	$("#divLog").css("display","block");
	hideMsgAguardo();