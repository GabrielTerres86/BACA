<?php

/* !
 * FONTE        : tab_cadpar.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 07/03/2013
 * OBJETIVO     : Mostrar tela a tabela CADPAR
 * --------------
 * ALTERAÇÕES   : 01/04/2015 - Adicionado novo parametro cdprodut. (Jorge/Rodrigo - SD 229250)
 * --------------
 */
?>
<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Inicializa
$procedure = '';
$retornoAposErro = '';

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$cdpartar = (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : 0;
$cdprodut = (isset($_POST['cdprodut'])) ? $_POST['cdprodut'] : 0;

// Dependendo da operação, chamo uma procedure diferente
$procedure = 'carrega-tabcadpar';

$retornoAposErro = 'focaCampoErro(\'cdtarifa\', \'frmCab\');';

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml dinâmico de acordo com a operação 
$xml = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0153.p</Bo>';
$xml .= '		<Proc>' . $procedure . '</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
$xml .= '		<cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
$xml .= '		<nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
$xml .= '		<cdoperad>' . $glbvars['cdoperad'] . '</cdoperad>';
$xml .= '		<dtmvtolt>' . $glbvars['dtmvtolt'] . '</dtmvtolt>';
$xml .= '		<cdpartar>' . $cdpartar . '</cdpartar>';
$xml .= '		<cdprodut>' . $cdprodut . '</cdprodut>';
$xml .= '		<flgerlog>YES</flgerlog>';
$xml .= '	</Dados>';
$xml .= '</Root>';

$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

//----------------------------------------------------------------------------------------------------------------------------------	
// Controle de Erros
//----------------------------------------------------------------------------------------------------------------------------------
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    exibirErro('error', $msgErro, 'Alerta - Ayllos', $retornoAposErro, false);
}

echo '<fieldset>';
echo '	<div class="divRegistros">';
echo '		<table>';
echo '			<thead>';
echo '				<tr>';
echo '					<th>' . utf8ToHtml('Cooperativa') . '</th>';
echo '					<th>' . utf8ToHtml('Conte&uacute;do') . '</th>';
echo '				</tr>';
echo '			</thead>';
echo '			<tbody>';


$parametros = $xmlObjeto->roottag->tags[0]->tags;

foreach ($parametros as $r) {

    echo '<tr>';
    echo '	<td id="tabcdcooper"><span>' . getByTagName($r->tags, 'cdcooper') . '</span>';
    echo getByTagName($r->tags, 'nmrescop');
    echo '	</td>';
    echo '	<td id="tabdsconteu"><span>' . getByTagName($r->tags, 'dsconteu') . '</span>';
    echo getByTagName($r->tags, 'dsconteu');
    echo '<input type="hidden" id="tabnmrescop" name="tabnmrescop" value=' . getByTagName($r->tags, 'nmrescop') . '>';
    echo '	</td>';
    echo '</tr>';
}

echo '			</tbody>';
echo '		</table>';
echo '	</div>';
echo '</fieldset>';

if ($cddopcao != 'C') {

    echo '<div id="divBotoesTabCadpar" style="margin-top:5px; margin-bottom :10px; text-align:center;">';
    echo '	<a href="#" class="botao" id="btIncluir"  >Incluir</a>';
    echo '	<a href="#" class="botao" id="btAlterar"  >Alterar</a>';
    echo '	<a href="#" class="botao" id="btExcluir"  >Excluir</a>';
    echo '	<a href="#" class="botao" id="btReplica"  >Replicar</a>';
    echo '</div>';
}
?>
