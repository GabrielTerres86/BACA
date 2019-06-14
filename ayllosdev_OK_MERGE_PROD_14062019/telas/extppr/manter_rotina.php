<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 28/07/2011 
 * OBJETIVO     : Rotina para manter as operações da tela EXTPPR
 * --------------
 * ALTERAÇÕES   : 05/06/2013 - Incluir b1wgen0155 e tratamento para listar cVlbloque (Lucas R.)
 *
 *                27/11/2017 - Inclusao do valor de bloqueio em garantia. PRJ404 - Garantia Empr.(Odirlei-AMcom)  
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
	$operacao		= (isset($_POST['operacao']))   ? $_POST['operacao']   : 0  ; 
	$nrdconta		= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ; 
	$idseqttl		=  1; 
	$nraplica		= (isset($_POST['nraplica']))   ? $_POST['nraplica']   : 0  ; 
	$dtiniper		= (isset($_POST['dtiniper']))   ? $_POST['dtiniper']   : '' ; 
	$dtfimper		= (isset($_POST['dtfimper']))   ? $_POST['dtfimper']   : '' ; 
	$qtdeExtppr		= (isset($_POST['qtdeExtppr'])) ? $_POST['qtdeExtppr'] : 0 ; 


	if ( $qtdeExtppr == '0' ) {
		$retornoAposErro = 'estadoInicial();';
	} else {
		$retornoAposErro = 'estadoExtrato();';
	}
	
	
	// Dependendo da operação, chamo uma procedure diferente
	switch($operacao) {
		case 'BP':  $procedure = 'Busca_Poupanca'; 									break;
		case 'BL':  $procedure = 'Busca_Lancamentos';	$retornoAposErro = '';		break;
		default:    $retornoAposErro   = 'estadoInicial();'; return false; 			break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0103.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';	
	$xml .= '		<cdprogra>extppr</cdprogra>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrctrrpp>'.$nraplica.'</nrctrrpp>';
	$xml .= '		<dtiniper>'.$dtiniper.'</dtiniper>';
	$xml .= '		<dtfimper>'.$dtfimper.'</dtfimper>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " $('#".$nmdcampo."').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	// Monta o xml de requisição
	$xmlJud  = "";
	$xmlJud .= "<Root>";
	$xmlJud .= "	<Cabecalho>";
	$xmlJud .= "		<Bo>b1wgen0155.p</Bo>";
	$xmlJud .= "		<Proc>retorna-valor-blqjud</Proc>";
	$xmlJud .= "	</Cabecalho>";
	$xmlJud .= "	<Dados>";
	$xmlJud .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlJud .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlJud .= "		<nrcpfcgc>0</nrcpfcgc>";
	$xmlJud .= "		<cdtipmov>0</cdtipmov>";
	$xmlJud .= "		<cdmodali>3</cdmodali>";
	$xmlJud .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlJud .= "	</Dados>";
	$xmlJud .= "</Root>";
	
		// Executa script para envio do XML
	$xmlResult = getDataXML($xmlJud);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjBlqJud = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBlqJud->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjBlqJud->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "  <nrdconta>".$nrdconta."</nrdconta>";    
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "BLOQ0001", "CALC_BLOQ_GARANTIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErro($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;
    $vlblqpou  = getByTagName($registros, 'vlblqpou');	
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Retorno
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( $operacao == 'BP' ) {
		$vlbloque = $xmlObjBlqJud->roottag->tags[0]->attributes['VLBLOQUE'];
		$registro 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		echo "cDtiniper.val('".getByTagName($registro,'dtiniper')."');";
		echo "cDtfimper.val('".getByTagName($registro,'dtfimper')."');";
		echo "cDtvctopp.val('".getByTagName($registro,'dtvctopp')."');";
		echo "cDddebito.val('".getByTagName($registro,'dddebito')."');";
		echo "cVlbloque.val('".formataMoeda($vlbloque)."');";
        echo "cVlblqpou.val('".formataMoeda($vlblqpou)."');";
		echo "cVlrdcapp.val('".formataMoeda(getByTagName($registro,'vlrdcapp'))."');";
		echo "controlaLayout();";
	} else if ( $operacao == 'BL' ) {
		$registro = $xmlObjeto->roottag->tags[0]->tags;
		preencheArray( $registro );
		echo "montarTabela( 0, 20 );";
	}

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Preenche o array
	//----------------------------------------------------------------------------------------------------------------------------------
	function preencheArray( $registro ) {

		$i = 0;
		foreach ( $registro as $r ) {
		
			echo 'var aux = new Array();';
		
			echo 'aux[\'dtmvtolt\'] = "<span>'.dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')) .'</span>'.getByTagName($r->tags,'dtmvtolt').'";';
			echo 'aux[\'dshistor\'] = "'.getByTagName($r->tags,'dshistor').'";';
			echo 'aux[\'nrdocmto\'] = "<span>'.getByTagName($r->tags,'nrdocmto').'</span>'.mascara(getByTagName($r->tags,'nrdocmto'), '###.###.###').'";';
			echo 'aux[\'indebcre\'] = "'.getByTagName($r->tags,'indebcre').'";';
			echo 'aux[\'vllanmto\'] = "<span>'.converteFloat(getByTagName($r->tags,'vllanmto'),'MOEDA').'</span> '.formataMoeda(trim(getByTagName($r->tags,'vllanmto'))).'";';
			echo 'aux[\'vlsldppr\'] = "'.getByTagName($r->tags,'vlsldppr').'";';
			
			if ( getByTagName($r->tags,'txaplica') != '0' ) {
				echo 'aux[\'txaplica\'] = "<span>'.converteFloat(getByTagName($r->tags,'txaplica'),'TAXA').'</span> '.formataTaxa(getByTagName($r->tags,'txaplica')).'";';
			} else {
				echo 'aux[\'txaplica\'] = "<span>0</span>";';
			}
			
			echo 'aux[\'cdagenci\'] = "'.getByTagName($r->tags,'cdagenci').'";';
			echo 'aux[\'cdbccxlt\'] = "'.getByTagName($r->tags,'cdbccxlt').'";';
			echo 'aux[\'nrdolote\'] = "<span>'.getByTagName($r->tags,'nrdolote').'</span>'.mascara(getByTagName($r->tags,'nrdolote'), '###.###').'";';
			
			// recebe
			echo 'arrayExtppr['.$i.'] = aux;';
			$i++;
			
		}
		
	
	}
	
	  
	
?>