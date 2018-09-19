<? 
/*!
 * FONTE        : busca_antecipacao.php
 * CRIAÇÃO      : Daniel Zimmermann        
 * DATA CRIAÇÃO : 12/06/2014 
 * OBJETIVO     : 
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
	
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$cdprogra 		= 'cet0001.pc_consulta_antecipacao';
	
	$retornoAposErro = 'focaCampoErro(\'cddopcao\', \'frmCab\');';
	/*
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	*/
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrctremp"]) || !isset($_POST["nrdconta"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$retornoAposErro,false);
	}else{
		$nrctremp = $_POST["nrctremp"];		
		$nrdconta = $_POST["nrdconta"];
		
		// Verifica se número da conta é um inteiro válido
		if (!validaInteiro($nrdconta)) exibirErro('error','Par&acirc;metros inv&aacute;lida.','Alerta - Aimaro',$retornoAposErro,false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "ANTECIP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
	//	$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
	//	exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
	}
	
	else{
	
	 //   $prestacao = $xmlObjeto->roottag->tags[0]->tags; 	
		$prestacao = $xmlObjeto->roottag->tags;
	
		echo '	<div class="divRegistros">';
		echo '		<table>';
		echo '			<thead>';
		echo '				<tr>';	
		echo '					<th><input type="checkbox" name="checkTodos" id="checkTodos" value="no" style="float:none; height:16;"/></th>';
		echo '					<th>Parcela</th>';
		echo '					<th>Data Vencimento</th>';
		echo '					<th>Data Pagamento</th>';
		echo '					<th>Valor Pago</th>';
		echo '				</tr>';
		echo '			</thead>';
		echo '			<tbody>';	
		
		$contador = 0;
		foreach( $prestacao as $r ) { 	

			$contador++;
		
			echo '<tr>';
			echo        '<td>'; // align='center' valign='center>';
		//	echo            '<input class="flgcheck" type="checkbox" value="no" style="float:none; height:16;"/>';
			echo            '<input class="flgcheck" type="checkbox" name="flgcheck'.$contador.'" id="flgcheck'.$contador.'" value="no" style="float:none; height:16;"/>';
		    echo        '</td>';
			echo		'<td><span>'.getByTagName($r->tags,'nrparepr').'</span>';
		    echo				     getByTagName($r->tags,'nrparepr');
			echo 		     '<input type="hidden" id="nrparepr'.$contador.'" name="nrparepr'.$contador.'" value="'.getByTagName($r->tags,'nrparepr').'" />';
		    echo		'</td>';
			echo		'<td><span>'.getByTagName($r->tags,'dtvencto').'</span>';
		    echo				     getByTagName($r->tags,'dtvencto');
			echo 		     '<input type="hidden" id="dtvencto'.$contador.'" name="dtvencto'.$contador.'" value="'.getByTagName($r->tags,'dtvencto').'" />';
		    echo		'</td>';
			echo		'<td><span>'.getByTagName($r->tags,'dtpagemp').'</span>';
		    echo				     getByTagName($r->tags,'dtpagemp');
			echo 		     '<input type="hidden" id="dtpagemp'.$contador.'" name="dtpagemp'.$contador.'" value="'.getByTagName($r->tags,'dtpagemp').'" />';
		    echo		'</td>';
			echo		'<td><span>'.converteFloat(getByTagName($r->tags,'vllanmto'),'MOEDA').'</span>';
		    echo				     formataMoeda(getByTagName($r->tags,'vllanmto'));
			echo 		     '<input type="hidden" id="vllanmto'.$contador.'" name="vllanmto'.$contador.'" value="'.formataMoeda(getByTagName($r->tags,'vllanmto')).'" />';
		    echo		'</td>';
			echo '</tr>'; 
		} 	
				
		echo '			</tbody>';
		echo '		</table>';
		echo '      <input type="hidden" id="qtparepr" name="qtparepr" value="'.$contador.'" />';
		echo '	</div>';
	
	}

?>
