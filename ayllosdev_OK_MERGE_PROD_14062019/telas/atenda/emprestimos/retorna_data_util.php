<?php
/*
 * FONTE        : retorna_data_util.php
 * CRIAÇÃO      : Gabriel (CECRED)
 * DATA CRIAÇÃO : 02/05/2012 
 * OBJETIVO     : Retornar a data de liberacao do emprestimo a partir da quantidade de dias.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

 session_start();
 require_once('../../../includes/config.php');
 require_once('../../../includes/funcoes.php');
 require_once('../../../includes/controla_secao.php');
 require_once('../../../class/xmlfile.php');
 isPostMethod(); 
 
 // Guardo os parâmetos do POST em variáveis
$dtmvtolt = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '' ;
$qtdialib = (isset($_POST['qtdialib'])) ? $_POST['qtdialib'] : '' ;
 
 
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0002.p</Bo>';
$xml .= '		<Proc>retornaDataUtil</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<dtmvtolt>'.$dtmvtolt.'</dtmvtolt>';            
$xml .= '		<qtdialib>'.$qtdialib.'</qtdialib>';            
$xml .= '	</Dados>';
$xml .= '</Root>'; 
 
 
$xmlResult = getDataXML($xml);		
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
	exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','',false);
} 
 
$dtlibera  = $xmlObjeto->roottag->tags[0]->attributes['DTLIBERA'];

echo 'hideMsgAguardo(); blockBackground(parseInt($("#divRotina").css("z-index")));'; 
 
echo "$('#dtlibera','#frmNovaProp').val('$dtlibera');";

echo "arrayProposta['dtlibera'] = '$dtlibera';";
 
?>
 
 