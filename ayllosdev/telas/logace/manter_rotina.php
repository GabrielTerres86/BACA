<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Guilherme Boettcher (Supero)
 * DATA CRIAÇÃO : 14/02/2013
 * OBJETIVO     : Rotina para manter as operações da tela LOGACE
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
	$cdcooper		= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ;
    $dsdatela		= (isset($_POST['dsdatela'])) ? $_POST['dsdatela'] : '' ;
    $idorigem       = (isset($_POST['idorigem'])) ? $_POST['idorigem'] : 0  ;
    $dtiniper		= (isset($_POST['dtiniper'])) ? $_POST['dtiniper'] : '' ;
	$dtfimper		= (isset($_POST['dtfimper'])) ? $_POST['dtfimper'] : '' ;
    $cdfiltro		= (isset($_POST['cdfiltro'])) ? $_POST['cdfiltro'] : 0  ;
    $operacao		= (isset($_POST['operacao'])) ? $_POST['operacao'] : 'P'; 
	$nrregist		= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;
	$nriniseq		= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
	$nrregdet		= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;
	$nrinidet		= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
	
	
	
	// Dependendo da operação, chamo uma procedure diferente
    if  ($operacao == 'P') {
        switch($cdfiltro) {
            case '1': $procedure = 'consulta-acessadas';	     break;  // Telas acessadas no período
            case '2': $procedure = 'consulta-nao-acessadas';     break;  // Telas NÃO acessadas no período
            case '3': $procedure = 'consulta-nunca-acessados';   break;  // Telas Nunca Acessadas
        }
    }
    else{  // Caso seja "D"etalhes
        $procedure = 'exibe-detalhes';
    }

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0013.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcopsel>'.$cdcooper.'</cdcopsel>';  // é a cooper que foi selecionada na tela
    $xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<dsdatela>'.$dsdatela.'</dsdatela>';
    $xml .= '		<idorigem>'.$idorigem.'</idorigem>';
	$xml .= '		<dtiniper>'.$dtiniper.'</dtiniper>';
	$xml .= '		<dtfimper>'.$dtfimper.'</dtfimper>';
    $xml .= '		<cdfiltro>'.$cdfiltro.'</cdfiltro>';
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'- Alerta - Ayllos -',$retornoAposErro,false);
    }else{
		$registros = $xmlObjeto->roottag->tags[0]->tags;
        $detalhes  = $xmlObjeto->roottag->tags[0]->tags;
    }

    $qtRegistros = count($registros);
    $qtDetalhes  = count($detalhes);

    if  ($operacao == 'P') {
        $qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
        include("tab_dados.php");
	}
    else{
        $qtregdet = $xmlObjeto->roottag->tags[0]->attributes['QTREGDET'];
        include("tab_detalhes.php");
    }
?>