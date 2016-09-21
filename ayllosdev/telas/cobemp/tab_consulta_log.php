<?php
/* !
 * FONTE        : tab_consulta_log.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 18/08/2015
 * OBJETIVO     : Tabela que apresenta logs boleto
 * --------------
 * ALTERAÇÕES   : 
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

$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0;
$nrcnvcob = (isset($_POST['nrcnvcob'])) ? $_POST['nrcnvcob'] : 0;

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrdocmto>" . $nrdocmto . "</nrdocmto>";
$xml .= "   <nrcnvcob>" . $nrcnvcob . "</nrcnvcob>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_COBEMP", "BUSCAR_LOG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

    exit();
} else {
    $registros = $xmlObj->roottag->tags[0]->tags;
    $qtregist = $xmlObj->roottag->tags[1]->cdata;
}
?>

<div id="divLogs" name="divLogs" >
    <br style="clear:both" />
    <div class="divRegistros">
        <table width="100%">
            <thead>
                <tr>
                    <th><?php echo utf8ToHtml('Data/Hora') ?></th>
                    <th><?php echo utf8ToHtml('Descrição') ?></th>
                    <th><?php echo utf8ToHtml('Operador') ?></th>
                </tr>
            </thead>
            <tbody>

                <?php
                $conta = 0;
                foreach ($registros as $r) {
                    $conta++;
                    ?>
                    <tr>
                        <td><span><?php
                                echo getByTagName($r->tags, 'dtaltera');
                                echo getByTagName($r->tags, 'hrtransa');
                                ?></span>
                            <?php echo getByTagName($r->tags, 'dtaltera') . ' / ' . getByTagName($r->tags, 'hrtransa'); ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'dslogtit'); ?></span>
                            <?php echo getByTagName($r->tags, 'dslogtit'); ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'nmoperad'); ?></span>
                            <?php echo getByTagName($r->tags, 'nmoperad'); ?>
                        </td>
                    </tr>
                    <?php
                }
                ?>

            </tbody>
        </table>
        <input type="hidden" id="qtdreg" name="qtdreg" value="<? echo $conta; ?>" />
    </div>
</div>


<div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>	
        <tr>
            <td>
                <?php
                if (isset($qtregist) and $qtregist == 0) {
                    $nriniseq = 0;
                }

                // Se a paginação não está na primeira, exibe botão voltar
                if ($nriniseq > 1) {
                    ?> <a class='paginacaoAnt'><<< Anterior</a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>
            </td>
            <td>
                <?php
                if (isset($nriniseq)) {
                    ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php
                    if (($nriniseq + $nrregist) > $qtregist) {
                        echo $qtregist;
                    } else {
                        echo ($nriniseq + $nrregist - 1);
                    }
                    ?> de <?php echo $qtregist; ?><?php
                }
                ?>
            </td>
            <td>
                <?php
                // Se a paginação não está na última página, exibe botão proximo
                if ($qtregist > ($nriniseq + $nrregist - 1)) {
                    ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>			
            </td>
        </tr>
    </table>
</div>

<div id="divBotoesTelefone" style="margin-bottom: 5px; margin-top: 10px; text-align:center;" >
    <a href="#" class="botao" id="btVoltar"  	onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
</div>

<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        consultarLog(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        consultarLog(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>