<?php
/* !
 * FONTE        : imprimir_dados.php
 * CRIA��O      : Rog�rius Milit�o (DB1)
 * DATA CRIA��O : 24/01/2012
 * OBJETIVO     : Faz as impress�es da tela DESCTO	
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */

session_cache_limiter("private");
session_start();

// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m�todo POST
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
$inresgat = $_POST['inresgat'];
$dtiniper = $_POST['dtiniper'];
$dtfimper = $_POST['dtfimper'];
$dsdopcao = $_POST['dsdopcao'];
$dsdvalor = $_POST['dsdvalor'];
$dschqcop = $_POST['dschqcop'];
$dtmvtolt = $cddopcao == 'R' ? $_POST['dtmvtolt'] : $glbvars['dtmvtolt'];
$cdagenci = $_POST['cdagenci'];

$procedure = '';

if ($cddopcao == 'M' and $nrdconta > 0) {
    $procedure = 'gera-cheques-resgatados';
} else if ($cddopcao == 'M') {
    $procedure = 'gera-cheques-resgatados-geral';
} else if ($cddopcao == 'R') {
    $procedure = 'gera-relatorio-lotes';
} else if ($cddopcao == 'O') {
    $procedure = "gera-conferencia-cheques";
}

// Monta o xml de requisi��o
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '           <Bo>b1wgen0018i.p</Bo>';
$xml .= '           <Proc>' . $procedure . '</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '           <cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
$xml .= '           <cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
$xml .= '           <nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
$xml .= '           <idorigem>' . $glbvars['idorigem'] . '</idorigem>';
$xml .= '           <nmdatela>' . $glbvars['nmdatela'] . '</nmdatela>';
$xml .= '           <cdprogra>DESCTO</cdprogra>';
$xml .= '           <dtmvtolt>' . $dtmvtolt . '</dtmvtolt>';
$xml .= '           <dsiduser>' . $dsiduser . '</dsiduser>';
$xml .= '           <nrdconta>' . $nrdconta . '</nrdconta>';
$xml .= '           <inresgat>' . $inresgat . '</inresgat>';
$xml .= '           <dtiniper>' . $dtiniper . '</dtiniper>';
$xml .= '           <dtfimper>' . $dtfimper . '</dtfimper>';
$xml .= '           <cdctalis>' . $dsdopcao . '</cdctalis>';
$xml .= '           <vlsupinf>' . $dsdvalor . '</vlsupinf>';
$xml .= '           <inchqcop>' . $dschqcop . '</inchqcop>';
$xml .= '           <cdagencx>' . $cdagenci . '</cdagencx>';
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObjDados = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra cr�tica
if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
    $msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
    ?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
    exit();
}

// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];

// Chama fun��o para mostrar PDF do impresso gerado no browser
visualizaPDF($nmarqpdf);
?>