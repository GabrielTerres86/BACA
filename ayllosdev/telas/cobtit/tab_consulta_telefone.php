<?php
/* !
 * FONTE        : tab_consulta_telefone.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 02/06/2018
 * OBJETIVO     : Tabela que apresenta Telefones
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
$xml .= "   <flcelula>0</flcelula>";
$xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
$xml .= "   <nrregist>" . $nrregist . "</nrregist>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "COBTIT", "COBTIT_BUSCAR_TELEFONE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getClassXML($xmlResult);
$root = $xmlObj->roottag;
// Se ocorrer um erro, mostra crítica
 
if ($root->erro){
    echo 'showError("error","'.htmlentities($root->erro->registro->dscritic).'","Alerta - Ayllos","hideMsgAguardo();");';
    exit;
}
$registros = $root->dados->find("telefone");
$qtregist = $root->dados->getAttribute("QTREGIST");
?>

<div id="divTelefone" name="divTelefone" >
    <textarea id="nrdddtelefo" style="width: 1px; height: 1px; "></textarea>
    <br style="clear:both" />
    <div class="divRegistros">
        <table width="100%">
            <thead>
                <tr>
                    <th><?php echo utf8ToHtml('Operadora') ?></th>
                    <th><?php echo utf8ToHtml('DDD') ?></th>
                    <th><?php echo utf8ToHtml('Telefone') ?></th>
                    <th><?php echo utf8ToHtml('Ramal') ?></th>
                    <th><?php echo utf8ToHtml('Identificacao') ?></th>
                    <th><?php echo utf8ToHtml('Setor') ?></th>
                    <th><?php echo utf8ToHtml('Pessoa de Contato') ?></th>  
                </tr>
            </thead>
            <tbody>

                <?php
                foreach ($registros as $r) {
                    ?> 
                    <tr><td><span><?php echo $r->nmopetfn; ?></span>
                            <?php echo $r->nmopetfn; ?>
                        </td>
                        <td><span><?php echo $r->nrdddtfc; ?></span>
                            <?php echo $r->nrdddtfc; ?>
                        </td>
                        <td><span><?php echo $r->nrtelefo; ?></span>
                            <?php echo $r->nrtelefo; ?>
                            <input type="hidden" id="nrtelefo" value="<?php echo $r->nrdddtfc.' '.$r->nrtelefo; ?>"/>
                        </td>
                        <td><span><?php echo $r->nrdramal; ?></span>
                            <?php echo $r->nrdramal; ?>
                        </td>
                        <td><span><?php echo $r->tptelefo; ?></span>
                            <?php echo $r->tptelefo; ?>
                        </td>
                        <td>
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
<div id="divBotoesTelefone" style="margin-bottom: 5px; margin-top: 10px; text-align:center;" >
    <a href="#" class="botao" id="btVoltar"  	onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
</div>

<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        consultarTelefone(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        consultarTelefone(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>