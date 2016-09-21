<? 
/*!
 * FONTE        : carrega_grid.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 20/03/2015
 * OBJETIVO     : Carregar grid com tarifas pendentes
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>
<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cdcooper		= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0 ;
	$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 	
	
	$retornoAposErro = 'focaCampoErro(\'cddopcao\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcopatu>'.$cdcooper.'</cdcopatu>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "DEBCCR", "DEBCCR_CARREGAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		exit();				
	}
	
	$tabela  = '	<div class="divRegistros">';
	$tabela .= '		<table width="100%">';
	$tabela .= '			<thead>';
	$tabela .= '				<tr>';
	$tabela .= '					<th>'.utf8ToHtml('Data Vencimento').'</th>';
	$tabela .= '					<th>'.utf8ToHtml('N&uacute;mero Documento').'</th>';
	$tabela .= '					<th>'.utf8ToHtml('Conta Cart&atilde;o').'</th>';
	$tabela .= '					<th>'.utf8ToHtml('Valor Pendente').'</th>';
	$tabela .= '				</tr>';
	$tabela .= '			</thead>';
	//$tabela .= '			<tbody>';
    //$tabela .= '			</tbody>';
	$tabela .= '		</table>';
	$tabela .= ' </div>';
	
	$parametros = $xmlObjeto->roottag->tags; 
	
	echo 'trocaBotao("Debitar");';
    echo "criaTabelaReg('$tabela');";
	
	$contador = 0;
	$registro = '';
	foreach( $parametros as $r ) { 		
		
		$registro .= '<tr>';		
		$registro .= '	<td id="rowid"><span>'.getByTagName($r->tags,'rowid').'</span>';
		$registro .= 				getByTagName($r->tags,'dtvencimento');
		$registro .= '	</td>';
		$registro .= '	<td id="tabdsconteu"><span>'.getByTagName($r->tags,'dsdocumento').'</span>';
		$registro .= 		        getByTagName($r->tags,'dsdocumento');
		$registro .= '	</td>';
		$registro .= '	<td id="tabdsconteu"><span>'.getByTagName($r->tags,'nrconta_cartao').'</span>';
		$registro .= 		        getByTagName($r->tags,'nrconta_cartao');
		$registro .= '	</td>';
		$registro .= '	<td id="tabdsconteu"><span>'.getByTagName($r->tags,'vlpendente').'</span>';
		$registro .= 		        getByTagName($r->tags,'vlpendente');
		$registro .= '	</td>';	
		$registro .= '</tr>';	
		
		$contador++;
		if($contador == 30){			
			echo "insereRegTabela('$registro');";
			$registro = '';
			$contador = 0;
			$control = false;
		}else{
			$control = true;
		}			
	}
	
	if($control){				
		echo "insereRegTabela('$registro');";	
	}

	echo "layoutTabela();";
	
	//$resumo = end($parametros);
	//$vltottar = getByTagName($resumo->tags,'vltottar');
	//$qtregtar = getByTagName($resumo->tags,'qtregtar');
	
	
	//echo "insereResumo('$qtregtar','$vltottar');";
	
//	echo 'alert("'.getByTagName($resumo->tags,'vltottar').'");';
//	echo 'alert("'.getByTagName($resumo->tags,'qtregtar').'");';
	
	
?>
