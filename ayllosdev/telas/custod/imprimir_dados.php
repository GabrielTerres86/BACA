<?php
/* !
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 30/01/2012
 * OBJETIVO     : Faz as impressões da tela CUSTOD	
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */


session_cache_limiter("private");
session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], $_POST['cddopcao'])) <> "") {
    ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
    exit();
}

$c = array('.', '-');

// Recebe as variaveis
$dsiduser = session_id();
$cddopcao = $_POST['cddopcao'];
$nrdconta = str_ireplace($c, '', $_POST['nrdconta']);
$dtmvtini = $_POST['dtmvtini'];
$dtmvtfim = $_POST['dtmvtfim'];
$cdagenci = $_POST['cdagenci'];
$flgrelat = $_POST['flgrelat'];
$nmdopcao = $_POST['nmdopcao'];
$inresgat = $_POST['inresgat'];
$dtiniper = $_POST['dtiniper'];
$dtfimper = $_POST['dtfimper'];
$dtcusini = $_POST['dtcusini'];
$dtcusfim = $_POST['dtcusfim'];
$dtlibera = $_POST['dtlibera'];
$protocolo = (!empty($_POST['protocolo'])) ? unserialize($_POST['protocolo']) : array();

$BO = 'b1wgen0018i.p';

if ($cddopcao == 'D') {
    $BO = 'b1wgen0018.p';
    $procedure = 'desconta_cheques_em_custodia';
} else if ($cddopcao == 'M') {
    $procedure = 'gera-custodia-cheques';
} else if ($cddopcao == 'O') {
    $procedure = 'gera-conferencia-custodia';
} else if ($cddopcao == 'R') {
    $procedure = 'gera-lotes-custodia';
}
// Monta o xml de requisição
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '           <Bo>'.$BO.'</Bo>';
$xml .= '           <Proc>' . $procedure . '</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '           <cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
$xml .= '           <cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
$xml .= '           <nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
$xml .= '           <idorigem>' . $glbvars['idorigem'] . '</idorigem>';
$xml .= '           <nmdatela>' . $glbvars['nmdatela'] . '</nmdatela>';
$xml .= '           <dtmvtolt>' . $glbvars['dtmvtolt'] . '</dtmvtolt>';
$xml .= '           <cdoperad>' . $glbvars['cdoperad'] . '</cdoperad>';
$xml .= '           <cdprogra>CUSTOD</cdprogra>';
$xml .= '           <nrdconta>' . $nrdconta . '</nrdconta>';
$xml .= '           <dtmvtini>' . $dtmvtini . '</dtmvtini>';
$xml .= '           <dtmvtfim>' . $dtmvtfim . '</dtmvtfim>';
$xml .= '           <cdagencx>' . $cdagenci . '</cdagencx>';
$xml .= '           <nmdopcao>' . $nmdopcao . '</nmdopcao>';
$xml .= '           <flgrelat>' . $flgrelat . '</flgrelat>';
$xml .= '           <dsiduser>' . $dsiduser . '</dsiduser>';
$xml .= '           <inresgat>' . $inresgat . '</inresgat>';
$xml .= '           <dtiniper>' . $dtiniper . '</dtiniper>';
$xml .= '           <dtfimper>' . $dtfimper . '</dtfimper>';
$xml .= '           <dtlibera>' . $dtlibera . '</dtlibera>';
$xml .= '   		<dtcusini>' . $dtcusini . '</dtcusini>';
$xml .= '	    	<dtcusfim>' . $dtcusfim . '</dtcusfim>';
$xml .= xmlFilho($protocolo, 'Cheques', 'Itens');
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObjDados = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
    $msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
    ?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
    exit();
}

// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];

// Chama função para mostrar PDF do impresso gerado no browser
visualizaPDF($nmarqpdf);
?>