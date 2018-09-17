<?php
/* !
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 23/09/2011
 * OBJETIVO     : Carregar dados para impressões do IMPRES	
 * --------------
 * ALTERAÇÕES   : 
 *   16/04/2012 -                       : Alterado a chamda da impressao da b1wgen0084 para b1wgen0112 
 *   10/09/2012 - Guilherme    (SUPERO) : Condicional para Procedure, se tipo Aplicacao
 *   07/04/2015 - David                 : Inclusão parametro intpextr
 *   08/08/2016 - Guilherme    (SUPERO) : M325 - Informe de Rendimentos Trimestral PJ
 * -------------- 
 */
?>

<?php
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


if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], "I")) <> "") {
    ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
    exit();
}

// Verifica se parâmetros necessários foram informados
if (!isset($_POST['nrdconta']) ||
        !isset($_POST['idseqttl']) ||
        !isset($_POST['tpextrat']) ||
        !isset($_POST['dtrefere']) ||
        !isset($_POST['dtreffim']) ||
        !isset($_POST['flgtarif']) ||
        !isset($_POST['inrelext']) ||
        !isset($_POST['inselext']) ||
        !isset($_POST['tpmodelo']) ||
        !isset($_POST['nrctremp']) ||
        !isset($_POST['nraplica']) ||
        !isset($_POST['nranoref'])) {
    ?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
    exit();
}

// Recebe as variaveis
$nrdconta = $_POST['nrdconta'];
$idseqttl = $_POST['idseqttl'];
$tpextrat = $_POST['tpextrat'];
$dtrefere = $_POST['dtrefere'];
$dtreffim = $_POST['dtreffim'];
$flgtarif = $_POST['flgtarif'];
$inrelext = $_POST['inrelext'];
$inselext = $_POST['inselext'];
$tpmodelo = $_POST['tpmodelo'];
$nrctremp = $_POST['nrctremp'];
$nraplica = $_POST['nraplica'];
$nranoref = $_POST['nranoref'];
$tpinform = isset($_POST['tpinform']) ? $_POST['tpinform'] : 0;  // 0 - Anual / 1 - Trimestral
$nrperiod = isset($_POST['nrperiod']) ? $_POST['nrperiod'] : 1;
$dsiduser = session_id();
$cdprogra = "IMPRES";

if ($tpextrat == '4') {
    $procedure = 'Gera_Impressao_Aplicacao';
    $dtextrat = explode("/", $dtreffim);
} else {
    $procedure = 'Gera_Impressao';
}

// Monta o xml de requisição
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0112.p</Bo>';
$xml .= '		<Proc>' . $procedure . '</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '		<cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
$xml .= '		<cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
$xml .= '		<nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
$xml .= '		<idorigem>' . $glbvars['idorigem'] . '</idorigem>';
$xml .= '		<nmdatela>' . $glbvars['nmdatela'] . '</nmdatela>';
$xml .= '		<dtmvtolt>' . $glbvars['dtmvtolt'] . '</dtmvtolt>';
$xml .= '		<dtmvtopr>' . $glbvars['dtmvtopr'] . '</dtmvtopr>';
$xml .= '		<cdprogra>' . $cdprogra . '</cdprogra>';
$xml .= '		<inproces>' . $glbvars['inproces'] . '</inproces>';
$xml .= '		<cdoperad>' . $glbvars['cdoperad'] . '</cdoperad>';
$xml .= '		<dsiduser>' . $dsiduser . '</dsiduser>';
$xml .= '		<flgrodar>yes</flgrodar>';
$xml .= '		<nrdconta>' . $nrdconta . '</nrdconta>';
$xml .= '		<idseqttl>' . $idseqttl . '</idseqttl>';
$xml .= '		<tpextrat>' . $tpextrat . '</tpextrat>';  // Tipos Extrato
$xml.= "		<intpextr>2</intpextr>";	
$xml .= '		<dtrefere>' . $dtrefere . '</dtrefere>';
$xml .= '		<dtreffim>' . $dtreffim . '</dtreffim>';
$xml .= "		<dtvctini>" . $dtrefere . "</dtvctini>";
$xml .= "		<dtvctfim>" . $dtreffim . "</dtvctfim>";
$xml .= '		<flgtarif>' . $flgtarif . '</flgtarif>';
$xml .= '		<inrelext>' . $inrelext . '</inrelext>';
$xml .= '		<inselext>' . $inselext . '</inselext>';
$xml .= "		<tprelato>" . $inselext . "</tprelato>"; // Especifico/Todos/Com Saldo/Sem Saldo
$xml .= '		<tpmodelo>' . $tpmodelo . '</tpmodelo>'; // 4) Demonstrativo/Sintetico/Analitico
$xml .= '		<nrctremp>' . $nrctremp . '</nrctremp>';
$xml .= '		<nraplica>' . $nraplica . '</nraplica>';
$xml .= '		<nranoref>' . $nranoref . '</nranoref>';
$xml .= "		<idimpres>" . $idimpres . "</idimpres>";
$xml .= "		<tpinform>" . $tpinform . "</tpinform>";
$xml .= "		<nrperiod>" . $nrperiod . "</nrperiod>";
$xml .= '		<flgerlog>yes</flgerlog>';
$xml .= '	</Dados>';
$xml .= '</Root>';

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObjDados = getObjectXML($xmlResult);
//print_r($xmlObjDados); exit;
// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
    $msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
    ?><script language="javascript">alert('<?php echo str_replace(chr(13),'\\n',str_replace(chr(10),'',$msg)); ?>');
                        window.close();</script><?php
    exit();
}

// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
 $nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];
    	
// Chama função para mostrar PDF do impresso gerado no browser
visualizaPDF($nmarqpdf);
?>