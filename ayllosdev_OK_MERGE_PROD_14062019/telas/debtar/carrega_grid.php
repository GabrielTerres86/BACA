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
	$cdagenci		= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0 ;	
	$inpessoa		= (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0 ;
	$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ; 	
	$cdhistor		= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0 ;
	$cddgrupo		= (isset($_POST['cddgrupo'])) ? $_POST['cddgrupo'] : 0 ; 	
	$cdsubgru		= (isset($_POST['cdsubgru'])) ? $_POST['cdsubgru'] : 0 ; 		
	$dtinicio		= (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : 0 ; 	
	$dtafinal		= (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : 0 ; 	
	
	$retornoAposErro = 'focaCampoErro(\'cdtarifa\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars["cdcooper"].'</cdcooper>';
	$xml .= '       <cdcopatu>'.$cdcooper.'</cdcopatu>';
	$xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
	$xml .= '		<cdoperad>'.$glbvars["cdoperad"].'</cdoperad>';
	$xml .= '		<inpessoa>'.$inpessoa.'</inpessoa>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '		<cdhistor>'.$cdhistor.'</cdhistor>';	
	$xml .= '		<cddgrupo>'.$cddgrupo.'</cddgrupo>';	
	$xml .= '		<cdsubgru>'.$cdsubgru.'</cdsubgru>';		
	$xml .= '		<dtinicio>'.$dtinicio.'</dtinicio>';
	$xml .= '		<dtafinal>'.$dtafinal.'</dtafinal>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = mensageria($xml, "DEBTAR", "DEBTAR_CARREGAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
		exit();				
	}
	
	$tabela  = '	<div class="divRegistros">';
	$tabela .= '		<table width="100%">';
	$tabela .= '			<thead>';
	$tabela .= '				<tr>';
	$tabela .= '					<th>'.utf8ToHtml('Cooperativa').'</th>';
	$tabela .= '					<th>'.utf8ToHtml('PA').'</th>';
	$tabela .= '					<th>'.utf8ToHtml('Conta').'</th>';
	$tabela .= '					<th>'.utf8ToHtml('Titular').'</th>';
	$tabela .= '					<th>'.utf8ToHtml('Data').'</th>';
	$tabela .= '					<th>'.utf8ToHtml('Tarifa').'</th>';
	$tabela .= '					<th>'.utf8ToHtml('Valor').'</th>';
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
		//$registro .= '	<td id="tabcdcooper"><span>'.getByTagName($r->tags,'nmrescop').'</span>';
		$registro .= '	<td id="rowid"><span>'.getByTagName($r->tags,'rowid').'</span>';
		$registro .= 				getByTagName($r->tags,'nmrescop');
		$registro .= '	</td>';
		$registro .= '	<td id="tabdsconteu"><span>'.getByTagName($r->tags,'cdagenci').'</span>';
		$registro .= 		        getByTagName($r->tags,'cdagenci');
		$registro .= '	</td>';
		$registro .= '	<td id="tabdsconteu"><span>'.getByTagName($r->tags,'nrdconta').'</span>';
		$registro .= 		        getByTagName($r->tags,'nrdconta');
		$registro .= '	</td>';
		$registro .= '	<td id="tabdsconteu"><span>'.getByTagName($r->tags,'nmprimtl').'</span>';
		$registro .= 		        getByTagName($r->tags,'nmprimtl');
		$registro .= '	</td>';
		$registro .= '	<td id="tabdsconteu"><span>'.getByTagName($r->tags,'dtmvtolt').'</span>';
		$registro .= 		        getByTagName($r->tags,'dtmvtolt');
		$registro .= '	</td>';		
		$registro .= '	<td id="tabdsconteu"><span>'.getByTagName($r->tags,'dstarifa').'</span>';
		$registro .= 		        getByTagName($r->tags,'dstarifa');
		$registro .= '	</td>';		
		$registro .= '	<td id="tabdsconteu"><span>'.getByTagName($r->tags,'vltarifa').'</span>';
		$registro .= 		        getByTagName($r->tags,'vltarifa');
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

	$resumo = end($parametros);
	$vltottar = getByTagName($resumo->tags,'vltottar');
	$qtregtar = getByTagName($resumo->tags,'qtregtar');
	
	
	echo "insereResumo('$qtregtar','$vltottar');";
	
//	echo 'alert("'.getByTagName($resumo->tags,'vltottar').'");';
//	echo 'alert("'.getByTagName($resumo->tags,'qtregtar').'");';
	
	
?>
