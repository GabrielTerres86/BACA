<? 
/*!
 * FONTE        : busca_rendas_automaticas.php
 * CRIAÇÃO      : Tiago
 * DATA CRIAÇÃO : 16/05/2016
 * OBJETIVO     : Rotina para buscar os rendas automaticas dependendo da lista de historicos parametrizadas na cadpar.
 *
 * ALTERACOES   : 
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
    $nrdconta = $_POST['nrdconta'] == '' ?  0  : $_POST['nrdconta'];

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";	
    $xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
    $xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xml .= "		<dtmvtoan>".$glbvars["dtmvtoan"]."</dtmvtoan>";	
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML
    $xmlResult = mensageria($xml, "CONTAS", "BUSCA_LANAUT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");     
    
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	$result = $xmlObjeto->roottag->tags;
	
?>

	var strHTML = ''; 
	
	strHTML = '<fieldset id="RendasAutomaticas">';
	strHTML += '<legend> Rendas Autom&aacute;tica </legend>';
	strHTML += '<div class="divRegistros">';
	strHTML += '  <table>';
	strHTML += '    <thead>';
	strHTML += '       <tr>';
	strHTML += '          <th>Data</th>';
	strHTML += '          <th>Descri&ccedil;&atilde;o</th>';
	strHTML += '          <th>Valor</th>';
	strHTML += '       </tr>';
	strHTML += '    </thead>';
	strHTML += '    <tbody>';
	
<?

	foreach($result as $meses){
		
		foreach($meses as $lancamentos){
			
			//print_r($lancamentos);
			
			foreach($lancamentos as $registro){
				//print_r($registro);
				
				if( trim(getByTagName($registro->tags,'dtalanca')) <> '' ){
			?>	
	strHTML += '     	       <tr>'; 	
	strHTML += '     	   	     <td><span><? echo getByTagName($registro->tags,'dtalanca'); ?></span><? echo getByTagName($registro->tags,'dtalanca'); ?> </td>';
	strHTML += '     	   	     <td><span><? echo getByTagName($registro->tags,'dshistor'); ?></span><? echo getByTagName($registro->tags,'dshistor'); ?> </td>';
	strHTML += '      	         <td><span><? echo getByTagName($registro->tags,'vlrlanca'); ?></span><? echo getByTagName($registro->tags,'vlrlanca'); ?> </td>';
	strHTML += '     	       </tr>';	
			<?
				}
					
			}
			
		}

			if( trim(getByTagName($meses->tags,'TotalLancMes')) <> '' ){
			?>
	strHTML += '     	       <tr>'; 	
	strHTML += '     	   	     <td><span></span> </td>';
	strHTML += '     	   	     <td><span></span><b>TOTAL DA REFERENCIA - <? echo getByTagName($meses->tags,'referencia'); ?> </b> </td>';
	strHTML += '      	         <td><span><? echo getByTagName($meses->tags,'TotalLancMes'); ?></span><b><? echo getByTagName($meses->tags,'TotalLancMes'); ?> </b></td>';
	strHTML += '     	       </tr>';				
			<?	
			}

		
	}
?>	
	
	strHTML += '     </tbody>';	
	strHTML += '  </table>';
	strHTML += '</div>';
	strHTML += '<div id="divRegistrosRodape" class="divRegistrosRodape">';
	strHTML += '	<table>';	
	strHTML += '		<tr>';
	strHTML += '			<td>';
	strHTML += '			</td>';
	strHTML += '			<td>';
	strHTML += '			</td>';
	strHTML += '			<td>';
	strHTML += '			</td>';
	strHTML += '        </tr>';
	strHTML += '	</table>';
	strHTML += '</div>';	
	strHTML += '</fieldset>';	
	
<?	
	echo "$('#divReferencia').html();";
	echo "$('#divReferencia').html(strHTML);";
	echo "tabelaReferencia('10');";
	echo "$('#frmDadosComercial').css('display','none');";
	echo "$('#divBotoes').css('display','none');";
	echo "$('#divReferencia').css('display','block');";	
	echo "$('#divBotoesRendas').css('display','block');";
	echo "$('#divConteudoOpcao').css('height','280');";
	echo "bloqueiaFundo(divRotina)";
?>	
