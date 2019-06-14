<?php
/* !
 * FONTE        : prestacoes.php
 * CRIAÇÃO      : Lucas Reinert/Daniel Zimmermann
 * DATA CRIAÇÃO : 12/08/2015
 * OBJETIVO     : Mostra rotina Cobranca de Emprestimos
 * --------------
 * ALTERAÇÃO    : 13/03/2017 - Criacao do form_arquivos.php. (P210.2 - Jaison/Daniel)
 * --------------
 */
?>

<?php
session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
require_once('../../class/xmlfile.php');


// Verifica se tela foi chamada pelo método POST
isPostMethod();


// Se parametros necessários não foram informados
if (!isset($_POST['nmdatela'])) {
    exibirErro('error', 'Parâmetros incorretos.', 'Alerta - Ayllos', '');
}

// Carrega permissões do operador
include('../../includes/carrega_permissoes.php');
?>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="Pragma" content="no-cache">
        <title><?php echo $TituloSistema; ?></title>
        <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="../../css/base/jquery.ui.all.css">
        <script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
        <script type="text/javascript" src="../../scripts/dimensions.js"></script>
        <script type="text/javascript" src="../../scripts/funcoes.js"></script>
        <script type="text/javascript" src="../../scripts/mascara.js"></script>
        <script type="text/javascript" src="../../scripts/menu.js"></script>
        <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
        <!--<script type="text/javascript" src="../../scripts/ui/jquery.js"></script>-->
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.core.js"></script>
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.datepicker.js"></script>
        <script type="text/javascript" src="../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
        <script type="text/javascript" src="prestacoes.js?keyrand=<?php echo mt_rand(); ?>"></script>
        <script type="text/javascript" src="cobemp.js?keyrand=<?php echo mt_rand(); ?>"></script>

    </head>
    <body>
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td><?php include("../../includes/topo.php"); ?></td>
            </tr>
            <tr>
                <td id="tdConteudo" valign="top">
                    <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td width="175" valign="top">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td id="tdMenu"><?php include("../../includes/menu.php"); ?></td>
                                    </tr>
                                </table>
                            </td>
                            <td id="tdTela" valign="top">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td>
                                            <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('COBEMP - Cobran&ccedil;a de Empr&eacute;stimos') ?></td>
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
                                                    <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td id="tdConteudoTela" class="tdConteudoTela" align="center">
                                            <table width="100%" border="0" cellpadding="3" cellspacing="0">
                                                <tr>
                                                    <td style="border: 1px solid #F4F3F0;">
                                                        <table width="100%" border="0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
                                                            <tr>
                                                                <td align="center">
                                                                    <table width="880" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
                                                                        <tr>
                                                                            <td>
                                                                                <!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
                                                                                <?php require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>

                                                                                <!-- INCLUDE DA TELA DE PESQUISA -->
                                                                                <? require_once("../../includes/pesquisa/pesquisa.php"); ?>

                                                                                <div id="divRotina"></div>
                                                                                <form name="frmImprimir" id="frmImprimir" action="<?php echo $UrlSite; ?>telas/cobemp/imprimir_relatorio.php" method="post">
                                                                                    <input type="hidden" name="idarquivo" id="idarquivo" value="">
                                                                                    <input type="hidden" name="flgcriti" id="flgcriti" value="">
                                                                                    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
                                                                                </form>														
                                                                                <div id="divTela">
                                                                                    <!-- INCLUDE DO CABEÇALHO -->
                                                                                    <?php include('form_cabecalho.php'); ?>
                                                                                    <?php include('form_manutencao.php'); ?>
                                                                                    <?php include('form_contratos.php'); ?>
                                                                                    <?php include('form_arquivos.php'); ?>
                                                                                    <div id="divBotoes" style="margin-bottom: 15px; text-align:center; margin-top: 15px;display:none"></div>
                                                                                    <div id="divManutencao"></div>
                                                                                    <div id="divUsoGenerico"></div>
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
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </body>
</html>
