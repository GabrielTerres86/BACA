<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 02/08/2011 
 * OBJETIVO     : Rotina para manter as operações da tela EXTRDA
 * --------------
 * ALTERAÇÕES   : 27/11/2017 - Inclusao do valor de bloqueio em garantia. PRJ404 - Garantia Empr.(Odirlei-AMcom)  
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
	$qtdeExtrda		= (isset($_POST['qtdeExtrda'])) ? $_POST['qtdeExtrda'] : 0  ;

	if ( $qtdeExtrda == '0' ) {
		$retornoAposErro = 'estadoInicial();';
	} else {
		$retornoAposErro = 'estadoExtrato();';
	}	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0103.p</Bo>';
	$xml .= '		<Proc>Busca_Aplicacoes</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdprogra>extrda</cdprogra>';	
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nraplica>'.$nraplica.'</nraplica>';
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
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " focaCampoErro('".$nmdcampo."','frmCab');"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
		
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Retorno
	//----------------------------------------------------------------------------------------------------------------------------------
	$dados 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	
	echo "cDsaplica.val('".getByTagName($dados,'dsaplica')."');";
	echo "cVlsdrdad.val('".formataMoeda(getByTagName($dados,'vlsdrdad'))."');";
	
	if ( getByTagName($dados,'tpaplrdc') == '0' ) {
		echo "cVlsdrdca.val('".formataMoeda(getByTagName($dados,'vllanmto'))." ".getByTagName($dados,'indebcre')."');";

	} else {
		echo "cVlsdrdca.val('".getByTagName($dados,'dtvencto')."');";
	}
	
	echo "cCdoperad.val('".getByTagName($dados,'cdoperad')."');";
	echo "cVlsdresg.val('".formataMoeda(getByTagName($dados,'sldresga'))."');";
	echo "cQtdiaapl.val('".getByTagName($dados,'qtdiaapl')."');";
	echo "cQtdiauti.val('".getByTagName($dados,'qtdiauti')."');";
	echo "cTxcntrat.val('".formataMoeda(getByTagName($dados,'txaplmax'))."');";
	echo "cTxminima.val('".formataMoeda(getByTagName($dados,'txaplmin'))."');";

	if ( getByTagName($dados,'tpaplica') == '7' ) {
		echo "rQtdiauti.html('Qt.Uteis:');";
	} else {
		echo "rQtdiauti.html('Carencia:');";
	}
	
	$aplicacao = $xmlObjeto->roottag->tags[1]->tags;
	preencheArray( $aplicacao,$dados );
	echo "montarTabela( 0, 30 );";
    
    
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
	$xmlJud .= "		<cdmodali>2</cdmodali>";
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
    $vlblqapl  = getByTagName($registros, 'vlblqapl');	
    
    echo "cVlbloque.val('".formataMoeda($vlbloque)."');";
    echo "cVlblqapl.val('".formataMoeda($vlblqapl)."');";
    

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Preenche o array
	//----------------------------------------------------------------------------------------------------------------------------------
	function preencheArray( $aplicacao, $dados ) {

		$i = 0;
		echo 'arrayExtrda.length = 0;';

		foreach ( $aplicacao as $e ) {
		
			echo 'var aux = new Array();';
		
			echo 'aux[\'dtmvtolt\'] = "<span>'.dataParaTimestamp(getByTagName($e->tags,'dtmvtolt')) .'</span>'.getByTagName($e->tags,'dtmvtolt').'";';
			echo 'aux[\'cdagenci\'] = "'.getByTagName($e->tags,'cdagenci').'";';
			echo 'aux[\'dshistoi\'] = "'.getByTagName($e->tags,'dshistor').'";';
			echo 'aux[\'nrdocmto\'] = "<span>'.getByTagName($e->tags,'nrdocmto').'</span>'.mascara(getByTagName($e->tags,'nrdocmto'),'###.###.###').'";';
			echo 'aux[\'indebcre\'] = "'.getByTagName($e->tags,'indebcre').'";';
			echo 'aux[\'vllanmto\'] = "<span>'.converteFloat(getByTagName($e->tags,'vllanmto'), 'MOEDA') .'</span>'.formataMoeda(getByTagName($e->tags,'vllanmto')).'";';

			if ( converteFloat(getByTagName($e->tags,'txaplica'), 'TAXA') > 0 ) {
				echo 'aux[\'txaplica\'] = "'.formataTaxa(getByTagName($e->tags,'txaplica')).'";';
			} else {
				echo 'aux[\'txaplica\'] = "";';
			}
			
			if ( getByTagName($e->tags,'vlpvlrgt') != '' ) {
				echo 'aux[\'vlpvlrgt\'] = "<span>'.converteFloat(getByTagName($e->tags,'vlpvlrgt')) .'</span>'.getByTagName($e->tags,'vlpvlrgt').'";';
			} else {
				echo 'aux[\'vlpvlrgt\'] = "";';
			}
			
			// recebe
			echo 'arrayExtrda['.$i.'] = aux;';
			$i++;
			
		}
		
	
	}
?>