<?
/*!
 * FONTE        : rating_ratbnd.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 21/11/2013
 * OBJETIVO     :
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
    session_start();

    // Includes para controle da session, variáveis globais de controle, e biblioteca de funções
    require_once("../../includes/config.php");
    require_once("../../includes/funcoes.php");

?>

<table id="rating"cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">
            <table border="0" cellpadding="0" cellspacing="0" width="228px">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="http://dwebayllos.cecred.coop.br/imagens/background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="http://dwebayllos.cecred.coop.br/imagens/background/tit_tela_fundo.gif">Rating</td>
                                <td width="12" id="tdTitTela" background="http://dwebayllos.cecred.coop.br/imagens/background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="http://dwebayllos.cecred.coop.br/imagens/geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="http://dwebayllos.cecred.coop.br/imagens/background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="tdConteudoTela" align="center">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <table border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td><img src="http://dwebayllos.cecred.coop.br/imagens/background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=acessaOpcaoAba(0,0,''); class="txtNormalBold">Principal</a></td>
                                            <td><img src="http://dwebayllos.cecred.coop.br/imagens/background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <div id="divConteudoRating" style="display:block">
                                        <div id="tabConteudoRating" style="display:block">
                                            <?
                                            $msgCritica = "Erro na atualiza&ccedil;&atilde;o do rating.";
                                            $flgFirst   = true;
                                            $style      = "";
                                            for ($i = 0; $i < $qtCriticas; $i++) {
                                                if ($criticas[$i]->tags[3]->cdata == 830) {
                                                    $msgCritica = $criticas[$i]->tags[4]->cdata;
                                                } else {
                                                    if ($flgFirst) {
                                                        $flgFirst = false;
                                                        ?>
                                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td>
                                                                    <table width="100%" border="0" cellpadding="0" cellspacing="2">
                                                                        <tr>
                                                                            <td width="100">
                                                                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                    <tr>
                                                                                        <td height="1" style="background-color:#999999;"></td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                            <td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">CR&Iacute;TICAS DO RATING</td>
                                                                            <td width="100">
                                                                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                    <tr>
                                                                                        <td height="1" style="background-color:#999999;"></td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <div id="divListaCriticasRating" style="overflow-y: scroll; overflow-x: hidden; height: 145px; width: 100%;">';
                                                                        <table width="445" border="0" cellpadding="1" cellspacing="2">
                                                    <?
                                                    }

                                                    if ($style == "") {
                                                        $style = ' style="background-color: #FFFFFF;"';
                                                    } else {
                                                        $style = "";
                                                    }

                                                    ?>
                                                                            <tr <?php echo $style; ?>>
                                                                                <td class="txtNormal"><?php echo $criticas[$i]->tags[4]->cdata; ?></td>
                                                                            </tr>
                                                    <?
                                                }

                                                if ($i == ($qtCriticas - 1)) {
                                                    ?>
                                                                        </table>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td height="8"></td>
                                                            </tr>
                                                            <tr>
                                                                <td align="center">
                                                                    <table border="0" cellpadding="0" cellspacing="3">
                                                                        <tr>
                                                                            <td><input type="image" name="btnCriticaRating" id="btnCriticaRating" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="eval(fncRatingSuccess);return false;"></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    <?
                                                }
                                            }
                                            ?>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>