<?php
/* !
 * FONTE        : impressao.php
 * CRIAÇÃO      : Daniel Zimmermann       
 * DATA CRIAÇÃO : 21/03/2016
 * OBJETIVO     : Rotina para impressão de relatorio.
 * --------------
 * ALTERAÇÕES   :  	03/11/2016 - Alterado o parametro insitapr, pois estava com 
 *								 o nome errado e assim o valor da pesquisa não 
 *								 era repassado para a rotina ( Renato Darosci - Supero)
 * -------------- 
 */
?> 

<?php
session_cache_limiter("private");
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Recebe Parametros
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
$cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
$dtinicio = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '';
$dtafinal = (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : '';
$insitest = (isset($_POST['insitest'])) ? $_POST['insitest'] : '';
$insitefe = (isset($_POST['insitefe'])) ? $_POST['insitefe'] : '';
$insitapr = (isset($_POST['insitapr'])) ? $_POST['insitapr'] : '';		
$tpproduto = (isset($_POST['tpproduto'])) ? $_POST['tpproduto'] : '9';

$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 999999;

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibeErroNew($msgError);
}


// Montar o xml de Requisicao
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrctremp>" . $nrctremp . "</nrctremp>";
$xml .= "   <codigopa>" . $cdagenci . "</codigopa>";
$xml .= "   <dtinicio>" . $dtinicio . "</dtinicio>";
$xml .= "   <dtafinal>" . $dtafinal . "</dtafinal>";
$xml .= "   <insitest>" . $insitest . "</insitest>";
$xml .= "   <insitefe>" . $insitefe . "</insitefe>";
$xml .= "   <insitapr>" . $insitapr . "</insitapr>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <tpproduto>" . $tpproduto . "</tpproduto>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";

$xml .= " </Dados>";
$xml .= "</Root>";

// craprdr / crapaca 
$xmlResult = mensageria($xml, "CONPRO", "CONPRO_IMPRESSAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

/*
  echo '<pre>';
  print_r($xmlObjeto);
  echo '</pre>';
 */

if (strtoupper($xmlObjeto->roottag->tags[0]->name == 'ERRO')) {

    $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    ?><script language="javascript">alert('<?php echo substr($msgErro, 0, 103); ?>');</script><?php
    exit();
} else {

    //Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    $nmarqpdf = $xmlObjeto->roottag->cdata;

    //Chama função para mostrar PDF do impresso gerado no browser	 
    visualizaPDF($nmarqpdf);
}


function exibeErroNew($msgErro) {
    ?><script language="javascript">alert('<?php echo substr($msgErro, 0, 103); ?>');</script><?php
    exit();
}
 