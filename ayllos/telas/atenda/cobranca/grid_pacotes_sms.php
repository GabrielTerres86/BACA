<?php

/* !
 * FONTE        : habilita_sms.php
 * CRIAÇÃO      : Ricardo Linhares
 * DATA CRIAÇÃO : 22/02/2017
 * OBJETIVO     : Rotina para exibir a habilitação do serviço de SMS
 */
?>

<?php

    session_start();
    require_once('../../../includes/config.php');
    require_once('../../../includes/funcoes.php');
    require_once('../../../includes/controla_secao.php');
    require_once('../../../class/xmlfile.php');
    isPostMethod();

    $inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : -1;
    $pagina = (isset($_POST['pagina'])) ? $_POST['pagina'] : 1;

    $tamanho_pagina = 4;

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
    $xml .= "   <flgstatus>1</flgstatus>";
    $xml .= "   <pagina>".$pagina."</pagina>";
    $xml .= "   <tamanho_pagina>".$tamanho_pagina."</tamanho_pagina>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "CADSMS", "LISTAR_PACOTES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', "", false);
    }

    $registros = $xmlObj->roottag->tags;

?>

<style>
    .labelFormPacote {
        width:150px;
    }

	.registroinput {
		width: 115px;
	}

</style>

    <!-- Grid -->
        <div id="divPacotes">
            <div class="divRegistros">
                <table>
                    <thead>
                        <tr>
                            <th><?php echo utf8ToHtml('Código'); ?></th>
                            <th><?php echo utf8ToHtml('Descrição do Pacote'); ?></th>
                            <th><?php echo utf8ToHtml('Qtd SMS'); ?></th>
                            <th><?php echo utf8ToHtml('Valor'); ?></th>
                        </tr>
                    </thead>
                    <tbody>

                        <?php foreach ($registros as $r) { ?>

                            <? $qtregist = getByTagName($r->tags, 'qtregist')  ?>

                            <tr id="<?php echo getByTagName($r->tags, 'idpacote') ?>" >
                                <td>
                                    <?php echo getByTagName($r->tags, 'idpacote') ?>
                                </td>
                                <td>
                                    <?php echo utf8ToHtml(getByTagName($r->tags, 'dspacote')) ?>
                                </td>
                                <td>
                                    <?php echo getByTagName($r->tags, 'qtdsms') ?>
                                </td>
                                <td>
                                    <?php echo getByTagName($r->tags, 'vlpacote') ?>
                                </td>
                            </tr>
                        <?php } ?>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="divPesquisaRodape" class="divPesquisaRodape">
            <table>
                <tr>
                    <td>
                        <?
                            if (isset($qtregist) and $qtregist == 0) $pagina = 0;

                            // Se a paginação não está na primeira, exibe botão voltar
                            if ($pagina > 1) {
                                ?> <a class='paginacaoAnt'><<< Anterior</a> <?
                            } else {
                                ?> &nbsp; <?
                            }
                        ?>
                    </td>
                    <td>
                        <?
                            if (isset($pagina) && $pagina > 0 && $qtregist > 0) {
                                ?> Exibindo <?
                                    echo ($pagina * $tamanho_pagina) - ($tamanho_pagina - 1); ?>
                                    at&eacute; <?

                                    if($pagina == 1) {
                                        if ($qtregist > $tamanho_pagina) {
                                            echo $tamanho_pagina;
                                        } else {
                                            echo $qtregist;
                                        }
                                    } else if (($pagina * $tamanho_pagina) > $qtregist) {
                                        echo $qtregist;
                                    } else {
                                        echo (($pagina * $tamanho_pagina) - ($tamanho_pagina) + $tamanho_pagina);
                                    } ?>
                                    de <? echo $qtregist; ?>
                        <?
                            }
                        ?>
                    </td>
                    <td>
                        <?
                            // Se a paginação não está na &uacute;ltima página, exibe botão proximo
                            if ($qtregist > ($pagina * $tamanho_pagina - 1) && $pagina > 0) {
                                ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
                            } else {
                                ?> &nbsp; <?
                            }
                        ?>
                    </td>
                </tr>
            </table>
        </div>

    <!-- Fim Grid -->


</form>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		Grid.carregar(<? echo "'".($pagina - 1)."'"; ?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		Grid.carregar(<? echo "'".($pagina + 1)."'"; ?>);
	});

	$('#divPesquisaRodape').formataRodapePesquisa();

</script>
