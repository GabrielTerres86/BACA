<?
/*!
 * FONTE        : consulta_contas_associ.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Outubro/2014
 * OBJETIVO     : Rotina para buscar as contas do associado
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

	// Recebe o POST
	$var_nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0  ;
	
	// Retira os caracteres do campo de CPF/CNPJ
	$nrcpfcgc = str_replace('.','',str_replace('-','',str_replace('/','',$var_nrcpfcgc)));
	
	$retornoAposErro = 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));btnOK3.prop(\'disabled\',false);cNrcpfcgc.habilitaCampo();focaCampoErro(\'nrcpfcgc\', \'frmCab\');';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "REAFOR", "CONTASS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

	// Recebendo os valores atraves de atriburos da TAG
	$nmprimtl  = $xmlObjeto->roottag->tags[0]->attributes['NMPRIMTL'];
	$lstconta  = $xmlObjeto->roottag->tags[0]->attributes['LSTCONTA'];
	$qtcontas  = $xmlObjeto->roottag->tags[0]->attributes['QTCONTAS'];

	// Separando as contas do associado
	$arrayconta = split(',',$lstconta);

	// Exibe o nome do associado no campod da tela
	echo "$('#nmprimtl','#frmCab').val('".$nmprimtl."');";

	// Monta a TAG option dinamicamente para cada conta do associado
	for ($i = 0; $i < $qtcontas; $i++) {
		echo "$('#nrdconta','#frmCab').append('<option value=".str_replace('.','',$arrayconta[$i]).">".$arrayconta[$i]."</option>');";
	}

	echo "cNrdconta.focus();";
	echo "cNrctremp.habilitaCampo();";
	echo "consultaContratoAssocido();";
	echo "cNrctremp.focus();";
?>