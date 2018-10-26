<?
/*!
 * FONTE        : limcrd.php
 * CRIAÇÃO      : Amasonas Borges Vieira Jr (Supero)
 * DATA CRIAÇÃO : 04/2018
 * OBJETIVO     : Mostrar tela LIMCRD - Cadastro de limite de crédito
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
require_once('supfn.php');
include("../../includes/carrega_permissoes.php");
isPostMethod();

?>
<html>
<head>
    <script>
    labels = {
        administradora: "<? echo utf8ToHtml("Administradora") ?>",
        codLimite: "<? echo utf8ToHtml("Cód. Limite") ?>",
        limite: "<? echo utf8ToHtml("Limite") ?>",
        limiteMin: "<? echo utf8ToHtml("Limite Mínimo") ?>",
        limiteMax: "<? echo utf8ToHtml("Limite Máximo") ?>",
        diasDBT: "<? echo utf8ToHtml("Dias Débito") ?>" ,
        ctaMae: "<? echo utf8ToHtml("Conta Mãe") ?>" ,
		alertaLinhaExistente: "<? echo utf8ToHtml("A linha de crédito solicitada já existe, por favor, selecione a opção de editar.") ?>"
    };
    </script>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <meta http-equiv="Pragma" content="no-cache">
    <title><? echo $TituloSistema; ?> ?keyrand=<?php echo mt_rand(); ?></title>
    <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="../../css/base/jquery.ui.all.css">
    <script type="text/javascript" src="../../scripts/scripts.js"></script>
    <script type="text/javascript" src="../../scripts/dimensions.js"></script>
    <script type="text/javascript" src="../../scripts/funcoes.js?keyrand=<?php echo mt_rand(); ?>"></script>
    <script type="text/javascript" src="../../scripts/mascara.js"></script>
    <script type="text/javascript" src="../../scripts/menu.js?keyrand=<?php echo mt_rand(); ?>"></script>
    <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
    <script type="text/javascript" src="../../scripts/ui/jquery.ui.core.js"></script>
    <script type="text/javascript" src="../../scripts/ui/jquery.ui.datepicker.js"></script>
    <script type="text/javascript" src="../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
    <script type="text/javascript" src="../../scripts/tooltip.js"></script>
    <script type="text/javascript" src="../../scripts/navegacao.js"></script>
    <script type="text/javascript" src="limcrd.js?var=<?php echo rand() ; ?>" ></script>

    <style>
        .clickable{
            cursor:pointer;
        }
        .clickable:hover{
            /* background-color: rgb(244, 243, 240);*/
            /*color: rgb(0, 0, 0); */
            cursor: pointer;
            outline: rgb(107, 121, 132) solid 1px;
        }
    </style>
</head>
<body>
<table  width="100%" border="0" cellpadding="0" cellspacing="0">
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
                        <table id="content" width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td>
                                    <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                            <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml("LIMCRD - Cadastramento de limite de cartões de crédito") ?> </td>
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
                                                            <table width="760" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
                                                                <tr>
                                                                    <td>
                                                                        <!-- INCLUDE DA TELA DE PESQUISA -->
                                                                        <? require_once("../../includes/pesquisa/pesquisa.php"); ?>

                                                                        <div id="divRotina"></div>
                                                                        <div id="divUsoGenerico"></div>
                                                                        <div id="divTela">
                                                                            <!-- Cabeçalho com as opções -->
                                                                            <? include('form_cabecalho.php'); ?>
                                                                            <table id="waiting">
                                                                                <tr><td> Carregando...</td> </tr>
                                                                            </table>
                                                                            <div  id="registrosDiv" class="hideable" >
                                                                                <div id="tabConcon">
                                                                                    <table class="tituloRegistros">
                                                                                        <thead>
                                                                                        <tr id="headertable">
                                                                                            <th id="admCell" class=" admCell">Administradora</th>
                                                                                            <th id="limCell" class=" limCell"><? echo utf8ToHtml("Limite Mínimo") ?></th>
                                                                                            <th id="limiteCell" class=" limiteCell"><? echo utf8ToHtml("Limite Máximo") ?></th>
                                                                                            <th id="diadebitoCell" class=" diadebitoCell"><? echo utf8ToHtml("Dias Débito") ?> </th>
                                                                                            <th id="tipocell" class="tipocell"><? echo utf8ToHtml("Cód") ?> </th>
                                                                                            <th id="nrctamaeCell" class="nrctamaeCell"><? echo utf8ToHtml("Conta Mãe") ?> </th>
                                                                                            <th class="ordemInicial"></th>
                                                                                        </tr>
                                                                                        </thead>
                                                                                    </table>
                                                                                </div>
                                                                                <div class=" divRegistros">
                                                                                    <table id="registros"  class=" tituloRegistros">
                                                                                        <thead>

                                                                                        <thead>
                                                                                        <tbody >

                                                                                        </tbody>
                                                                                    </table>
                                                                                </div>
                                                                                <table style="width: 100%;">
                                                                                    <tbody>
                                                                                    <tr style="height: 18px;">
                                                                                        <td style="text-align: center; background-color: rgb(247, 211, 206); color: rgb(51, 51, 51); padding: 0px 5px; font-size: 10px; width: 20%;"><a id="bkbtn" onclick="pagination('bac')"  class="paginacaoAnt" style="width: 99%; display: block; cursor: pointer; color: rgb(51, 51, 51); font-size: 10px; text-decoration: none; display:none">&lt;&lt;&lt; Anterior</a></td>
                                                                                        <td style="text-align: center; background-color: rgb(247, 211, 206); color: rgb(51, 51, 51); padding: 0px 5px; font-size: 10px; width: 60%;"> <? echo utf8ToHtml('Página') ?> <span id="pageStr"></span></td>
                                                                                        <td style="text-align: center; background-color: rgb(247, 211, 206); color: rgb(51, 51, 51); padding: 0px 5px; font-size: 10px; width: 20%;"><a id="fwbtn" class="paginacaoProx" onclick="pagination('fow')" style="width: 99%; display: block; cursor: pointer; color: rgb(51, 51, 51); font-size: 10px; text-decoration: none;"><? echo utf8ToHtml("Próximo"); ?>  &gt;&gt;&gt;</a></td>
                                                                                    </tr>
                                                                                    </tbody>
                                                                                </table>
                                                                            </div>
                                                                            <!-- INCLUDE do formulário -->
                                                                            <div id="cadastros">

                                                                            </div>
                                                                            <?// include('form_cadastro_limite.php'); ?>
                                                                            <div id="divBotoes" style='border-top:1px solid #777'>
                                                                                <a href="#" class="botao" id="btVoltar"   >Voltar</a>
                                                                                <a href="#" class="botao" id="btConcluir" onclick="salvarLimite()" >Concluir</a>
                                                                                <a  href="#" 
                                                                                    class="botao" 
                                                                                    id="btnExcluir" 
                                                                                    onclick="showConfirmacao('<? echo utf8ToHtml("Deseja excluir este registro?") ?>', 'Confirma&ccedil;&atilde;o - Aimaro', 'excluirLimite()', '', 'sim.gif', 'nao.gif');"> Excluir</a>
                                                                                <div class="hideable navbtn">

                                                                                   

                                                                                </div>

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