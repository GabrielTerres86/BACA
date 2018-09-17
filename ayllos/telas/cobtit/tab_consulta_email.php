<?php
/* !
 * FONTE        : tab_consulta_email.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 02/06/2018
 * OBJETIVO     : Tabela que apresenta Emails
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

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "COBTIT", "COBTIT_BUSCAR_EMAIL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getClassXML($xmlResult);
$root = $xmlObj->roottag;
// Se ocorrer um erro, mostra crítica
 
if ($root->erro){
    echo 'showError("error","'.htmlentities($root->erro->registro->dscritic).'","Alerta - Ayllos","hideMsgAguardo();");';
    exit;
}
$registros = $root->dados->find("email");
$qtregist = $root->dados->getAttribute("QTREGIST");
?>

<div id="divEmail" name="divEmail" >
    <br style="clear:both" />
    <div class="divRegistros">
        <table width="100%">
            <thead>
                <tr>
                    <th><?php echo utf8ToHtml('Email') ?></th>
                    <th><?php echo utf8ToHtml('Setor') ?></th>
                    <th><?php echo utf8ToHtml('Pessoa de Contato') ?></th>
                </tr>
            </thead>
            <tbody>

                <?php
                $conta = 0;
                foreach ($registros as $r) {
                    $conta++;
                    ?>
                    <tr>
                        <td><span><?php echo $r->dsdemail; ?></span>
                            <?php echo $r->dsdemail; ?>
                        </td>
                        <td><span><?php echo $r->secpscto; ?></span>
                            <?php echo $r->secpscto; ?>
                        </td>
                        <td><span><?php echo $r->nmpescto; ?></span>
                            <?php echo $r->nmpescto; ?>
                        </td>
                    </tr>
                    <?php
                }
                ?>

            </tbody>
        </table>
        <input type="hidden" id="qtdreg" name="qtdreg" value="<? echo $qtregist; ?>" />
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

<div id="divBotoesEmail" style="margin-bottom: 5px; margin-top: 10px; text-align:center;" >
    <a href="#" class="botao" id="btVoltar" onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
</div>

<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        consultarEmail(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        consultarEmail(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>