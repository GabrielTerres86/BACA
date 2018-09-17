<?php
/*!
 * FONTE        : imgchq.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 15/06/2012
 * OBJETIVO     : Mostrar tela IMGCHQ
 * --------------
 * ALTERAÇÕES   : 23/07/2012 - Adicionado biblioteca UI jquery para utilizar recurso de calendario. (Jorge)
 *
 *                15/03/2016 - Projeto 316 - Flag para Salvar Imagem e imgchq.js com MT_RAND. (Guilherme/SUPERO)
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

    require_once("../../includes/carrega_permissoes.php");

    setVarSession("opcoesTela",$opcoesTela);

?>

<script>
    var dtmvtolt = '<? echo $glbvars['dtmvtolt']?>';
    var cooploga = '<? echo $glbvars['cdcooper']?>';
    var flgSvImg = <? echo ((in_array("S", $opcoesTela) && $glbvars['cdcooper'] == 3) == 1)? 'true' : 'false' ?>;
</script>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="Pragma" content="no-cache">
        <title><? echo $TituloSistema; ?></title>
        <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="../../css/base/jquery.ui.all.css">
        <script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
        <script type="text/javascript" src="../../scripts/dimensions.js"></script>
        <script type="text/javascript" src="../../scripts/funcoes.js"></script>
        <script type="text/javascript" src="../../scripts/mascara.js"></script>
        <script type="text/javascript" src="../../scripts/menu.js"></script>
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.core.js"></script>
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.datepicker.js"></script>
        <script type="text/javascript" src="../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
        <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
        <script type="text/javascript" src="imgchq.js?keyrand=<?php echo mt_rand(); ?>"></script>
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
                                            <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('IMGCHQ - Consulta Imagem') ?></td>
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
                                                            <table width="800" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
                                                                <tr>
                                                                    <td>
                                                                        <div id="divTela">
                                                                            <? include('form_consulta_imagem.php'); ?>
                                                                        </div>
                                                                        <form id="frmImpressao">
                                                                            <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
                                                                        </form>
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