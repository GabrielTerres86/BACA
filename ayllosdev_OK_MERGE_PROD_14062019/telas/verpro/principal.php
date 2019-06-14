<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 27/10/2011
 * OBJETIVO     : Capturar dados para tela VERPRO
 * --------------
 * ALTERAÇÕES   : 16/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 
				  01/08/2014 - Alterar o programa para realizar as chamadas do Oracle ( Renato - Supero )
				  
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
		
	function execucao(){ 
		$sec = explode(" ",microtime());
		 $tempo = $sec[1] + $sec[0];
		 return $tempo; 
	}
	
	$inicio = execucao();
		
	// Recebe o POST
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$datainic = (isset($_POST['datainic'])) ? $_POST['datainic'] : '' ;
	$datafina = (isset($_POST['datafina'])) ? $_POST['datafina'] : '' ;
	$cdtippro = (isset($_POST['cdtippro'])) ? (is_array($_POST['cdtippro']) ? $_POST['cdtippro'][0] : $_POST['cdtippro']) : 0  ;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0 ; 
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0 ; 
	
	switch($operacao) {
		case 'BD': $procedure = 'Busca_Dados'; $tpdbusca = '1'; break;
		case 'BP': $procedure = 'Busca_Protocolos'; $tpdbusca = '2'; break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','',false);
	
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
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<dataini>'.$datainic.'</dataini>';
	$xml .= '		<datafin>'.$datafina.'</datafin>';
	$xml .= '		<cdtippro>'.$cdtippro.'</cdtippro>';
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '		<tpdbusca>'.$tpdbusca.'</tpdbusca>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "VERPRO", "CONSPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
	$xmlObjeto 	= getObjectXML($xmlResult);	
	
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Aimaro','cNrdconta.focus();',false);
	} 
	
	if ( $operacao == 'BD' ) {
		$datainic	= $glbvars['dtmvtolt'];
		$datafina	= $glbvars['dtmvtolt'];
		$nmprimtl	= $xmlObjeto->roottag->tags[0]->attributes['NMPRIMTL'];
		$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];		
	} 
	
	include('form_cabecalho.php');
	
	if ( $operacao == 'BP' ) { 
		$registros 	= $xmlObjeto->roottag->tags[0]->tags;
		$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
		include('tab_verpro.php'); 
	}
	
	// Após a execução da página, geramos a variavel $fim, que nos dará o tempo final da execução da página
 $fim = execucao();
 
// Agora é só fazermos a subtração de um pelo outro, e usar o number_format() do PHP para formatar com 6 casas depois da virgula e pronto, mas caso você queira alterar esse número de casas depois da vírgula para mais ou menos, fique a vontade
 $tempo = number_format(($fim-$inicio),6);
 
// Agora á só imprimir o resultado
 //print "Tempo de Execucao: <b>".$tempo."</b> segundos";
	
?>

<script>
controlaLayout('<? echo $operacao ?>');
</script>