<?php
/* !
 * FONTE        : conpro.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/03/2016
 * OBJETIVO     : Mostrar tela CONPRO
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

// Carrega permissões do operador
include("../../includes/carrega_permissoes.php");

setVarSession("opcoesTela", $opcoesTela);
?>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">	
        <meta http-equiv="Pragma" content="no-cache">
        <title><?php echo $TituloSistema; ?></title>
        <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
        <script type="text/javascript" src="../../scripts/scripts.js" charset="utf-8"></script>
        <script type="text/javascript" src="../../scripts/dimensions.js"></script>
        <script type="text/javascript" src="../../scripts/funcoes.js"></script>
        <script type="text/javascript" src="../../scripts/mascara.js"></script>
        <script type="text/javascript" src="../../scripts/menu.js"></script>
        <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
        <script>
             var situacoes = [];
                    situacoes[0] = {  
                        '9':'Todos',
                        '0':'<?php echo utf8ToHtml("Não enviada"); ?>',
                        '1':'<?php echo utf8ToHtml("Env. P/ Análise autom."); ?>',
                        '2':'<?php echo utf8ToHtml("Env. P/ Análise manual"); ?>',
                        '3':'<?php echo utf8ToHtml("Análise Finalizada"); ?>',
                        '4':'<?php echo utf8ToHtml("Expirado"); ?>'                        
                    };
                    situacoes[3] = {  
                        '9':'Todos',
                        '3':'<?php echo utf8ToHtml("Análise Finalizada"); ?>',
                        '1':'<?php echo utf8ToHtml("Env. P/ Análise autom."); ?>',
                        '2':'<?php echo utf8ToHtml("Env. P/ Análise manual"); ?>',
                        '4':'<?php echo utf8ToHtml("Expirado"); ?>'
                    };
                    situacoes[4] = {  
                        '9':'Todos',
                        '0':'Estudo',
                        '1':'Aprovada',
                        '2':'Solicitada',
                        '3':'Liberada',
                        '4':'Em uso',
                        '5':'Cancelada',
                        '6':'<?php echo utf8ToHtml("Em análise"); ?>',
                        '7':'Enviado Bancoob'                        
                    };
                    var parecer=[];
                    parecer[0] = {
                        '9':'Todos',
                        '0':"<?php echo utf8ToHtml("Não analisado"); ?>",
                        '1':"Aprovado",
                        '2':"Rejeitado",
                        '3':"<?php echo utf8ToHtml("Com Restrição"); ?>",
                        '4':"Refazer",
                        '5':"Derivar",
                        '6':"Erro"
                        
                    };
                    parecer[3] = {  
                        '9':'Todos',
                        '0':"<?php echo utf8ToHtml("Não analisado"); ?>",
                        '1':"Aprovado",
                        '2':"<?php echo utf8ToHtml("Não Aprovado"); ?>",
                        '3':"<?php echo utf8ToHtml("Com Restrição"); ?>",
                        '4':"Refazer",
                        '5':"Erro Consultar"
                    };
                    parecer[4] = {
                        '9':'Todos',
                        '1':"<?php echo utf8ToHtml("Sem aprovação"); ?>",
                        '2':"Aprovada Auto",
                        '3':"Erro",
                        '4':"Rejeitada",
                        '5':"Refazer",
                        '6':"Expirada",
                        
                    };
        </script>
        <script type="text/javascript" src="conpro.js?version=<?php echo rand();?>"></script>
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
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('CONPRO - Consulta Proposta') ?></td>
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
                                                                    <table width="1100" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
                                                                        <tr>
                                                                            <td>
                                                                                <!-- INCLUDE DA TELA DE PESQUISA -->
                                                                                <?php require_once("../../includes/pesquisa/pesquisa.php"); ?>

                                                                                <!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
                                                                                <?php require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>

                                                                                <div id="divRotina"></div>
                                                                                <div id="divUsoGenerico"></div>

                                                                                <div id="divTela">
                                                                                    <?php include('form_cabecalho.php'); ?>
                                                                                    <?php include('form_conpro.php'); ?>
                                                                                    <?php include('form_acionamento.php'); ?>
																					
																					<div name="divBotoes" id="divBotoes" style="margin-top:5px; margin-bottom :10px; display:block;">
																						<a href="#" class="botao" id="btVoltar" onclick="estadoInicial();
																								return false;">Voltar</a>
																						<a href="#" class="botao" id="btContinuar" onClick="controlaOperacao();
																								return false;">Continuar</a>
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