<?php
/* !
 * FONTE        : valbol.php
 * CRIACAO      : Carlos Rafael Tanholi / CECRED
 * DATA CRIACAO : 24/04/2015
 * OBJETIVO     : Tela VALBOL
 * --------------
 * ALTERACOES   :
 * --------------
 */

session_start();

// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
require_once('../../class/xmlfile.php');


// Verifica se tela foi chamada pelo metodo POST
isPostMethod();

// Carrega permissos do operador
include("../../includes/carrega_permissoes.php");
?>

<html>   
    <head> 
        <title><?php echo $TituloSistema; ?></title>
        <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
        <link href="valbol.css" rel="stylesheet" type="text/css">

        <script type="text/javascript" src="../../scripts/scripts.js"></script>
        <script type="text/javascript" src="../../scripts/dimensions.js"></script>
        <script type="text/javascript" src="../../scripts/funcoes.js"></script>
        <script type="text/javascript" src="../../scripts/mascara.js"></script>
        <script type="text/javascript" src="../../scripts/menu.js"></script>	
        <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
        <script type="text/javascript" src="valbol.js"></script>
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
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">VALBOL - Validador de Boletos</td>
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
                                                    <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>						  
                                                </tr>
                                            </table>
                                        </td>								
                                    </tr>				
                                    <tr>
                                        <td id="tdConteudoTela" class="tdConteudoTela" align="center"> 
                                            <table width="100%"  border= "0" cellpadding="3" cellspacing="0">
                                                <tr>
                                                    <td style="border: 1px solid #F4F3F0;">
                                                        <table width="100%"  border= "0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
                                                            <tr>
                                                                <td align="center">
                                                                    <table width="545" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
                                                                        <tr>
                                                                            <td>
                                                                                <!-- INCLUDE DA TELA DE PESQUISA -->
                                                                                <?php require_once("../../includes/pesquisa/pesquisa.php"); ?>	

                                                                                <div id="divRotina"></div>
                                                                                <div id="divUsoGenerico"></div>
                                                                                <div id="divTela">
                                                                                    <input type="hidden" value="<?php echo $glbvars["cdcooper"]; ?>" id="glb_cdcooper" />
                                                                                    <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                        <tr>
                                                                                            <td height="1" colspan="5" bgcolor="#999999"></td>
                                                                                        </tr>                                                                                        
                                                                                        <tr>
                                                                                            <td height="5" colspan="5"></td>
                                                                                        </tr>                                                                                        
                                                                                        <tr>
                                                                                            <td width="180" height="20" class="linkMenuAdmin">Selecione o tipo de pagamento: </td>
                                                                                            <td width="25" align="center" nowrap><input name="aux_dstpdpag" type="radio" onClick="setaFocoOpcao('titulo', document.frmTitulo);" value="titulo" checked></td>
                                                                                            <td width="30" nowrap class="txtNormal">T&iacute;tulo</td>
                                                                                            <td width="25" align="center" nowrap><input name="aux_dstpdpag" type="radio" value="fatura" onClick="setaFocoOpcao('fatura', document.frmFatura);"></td>
                                                                                            <td nowrap class="txtNormal">Fatura</td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td height="5" colspan="5"></td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td height="1" colspan="5" bgcolor="#999999"></td>
                                                                                        </tr>
                                                                                    </table>
                                                                                    <div id="divTitulo" style="display: block;">
                                                                                        <form action="" method="post" name="frmTitulo" id="frmTitulo">
                                                                                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td height="20" class="linkMenuAdmin">Linha Digit&aacute;vel:</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                                            <tr>
                                                                                                                <td width="90" height="20"><input name="aux_lindigi1" type="text" class="Campo" id="aux_lindigi1" style="width: 80px;" onKeyPress="return validaNumero(event);" onKeyUp="formataLinhaDigitavel(this, this.form.aux_lindigi2, 5, '.');
                                                                                                                        desabilitaCampos('T', 'LD', this.form);" value="" maxlength="11"></td>
                                                                                                                <td width="96"><input name="aux_lindigi2" type="text" class="Campo" id="aux_lindigi2" style="width: 86px;" onKeyPress="return validaNumero(event);" onKeyUp="formataLinhaDigitavel(this, this.form.aux_lindigi3, 5, '.');
                                                                                                                        desabilitaCampos('T', 'LD', this.form);" value="" maxlength="12"></td>
                                                                                                                <td width="96"><input name="aux_lindigi3" type="text" class="Campo" id="aux_lindigi3" style="width: 86px;" onKeyPress="return validaNumero(event);" onKeyUp="formataLinhaDigitavel(this, this.form.aux_lindigi4, 5, '.');
                                                                                                                        desabilitaCampos('T', 'LD', this.form);" value="" maxlength="12"></td>
                                                                                                                <td width="33"><input name="aux_lindigi4" type="text" class="Campo" id="aux_lindigi4" style="width: 23px;" onKeyPress="return validaNumero(event);" onKeyUp="formataLinhaDigitavel(this, this.form.aux_lindigi5, 0, '');
                                                                                                                        desabilitaCampos('T', 'LD', this.form);" value="" maxlength="1"></td>
                                                                                                                <td width="111"><input name="aux_lindigi5" type="text" class="Campo" id="aux_lindigi5" style="width: 101px;" onKeyPress="return validaNumero(event);" onKeyUp="formataLinhaDigitavel(this, this.form.btnOK, 0, '');
                                                                                                                        desabilitaCampos('T', 'LD', this.form);" value="" maxlength="14"></td>
                                                                                                                <td><input name="btnOK" type="button" class="botao_validar" id="btnOK" value="OK" onClick="valida_documento(this.form, 'T');"></td>						
                                                                                                            </tr>
                                                                                                        </table>
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td height="20" class="linkMenuAdmin">C&oacute;digo de Barras:</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td><input name="aux_cdbarras" type="text" class="Campo" id="aux_cdbarras" style="width: 285px;" value="" maxlength="44" onKeyPress="return validaNumero(event);" onKeyUp="desabilitaCampos('T', 'CB', this.form);onReadCodBarras(this.form, 'T');"></td>			
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td height="5" colspan="5"></td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td height="1" colspan="5" bgcolor="#999999"></td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td height="5" colspan="5"></td>
                                                                                                </tr>			
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                                            <tr>
                                                                                                                <td width="106" nowrap class="txtNormal">Data de Vencimento: </td>
                                                                                                                <td width="85"><input name="aux_dtvencto" type="text" class="Campo" id="aux_dtvencto" style="width: 75px;" value="" readonly="yes"></td>
                                                                                                                <td width="106" nowrap class="txtNormal">Valor do Documento: </td>
                                                                                                                <td width="115"><input name="aux_vlrdocum" type="text" class="Campo" id="aux_vlrdocum" style="width: 100px;" value="" readonly="yes"></td>
                                                                                                                <td><input name="btnLimpar" type="button" class="botao_validar" id="btnLimpar" value="Limpar" onClick="limparCampos(this.form, 'T');"></td>
                                                                                                            </tr>
                                                                                                        </table>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>			
                                                                                        </form> 
                                                                                    </div>		
                                                                                    <div id="divFatura" style="display: none;">
                                                                                        <form action="" method="post" name="frmFatura" id="frmFatura">
                                                                                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td height="20" class="linkMenuAdmin">Linha Digit&aacute;vel:</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                                            <tr>
                                                                                                                <td width="100" height="20"><input name="aux_lindigi1" type="text" class="Campo" id="aux_lindigi1" style="width: 95px;" value="" onKeyPress="return validaNumero(event);" onKeyUp="formataLinhaDigitavel(this, this.form.aux_lindigi2, 11, '-');
                                                                                                                        desabilitaCampos('F', 'LD', this.form);" maxlength="13"></td>
                                                                                                                <td width="100"><input name="aux_lindigi2" type="text" class="Campo" id="aux_lindigi2" style="width: 95px;" value="" onKeyPress="return validaNumero(event);" onKeyUp="formataLinhaDigitavel(this, this.form.aux_lindigi3, 11, '-');
                                                                                                                        desabilitaCampos('F', 'LD', this.form);" maxlength="13"></td>
                                                                                                                <td width="100"><input name="aux_lindigi3" type="text" class="Campo" id="aux_lindigi3" style="width: 95px;" value="" onKeyPress="return validaNumero(event);" onKeyUp="formataLinhaDigitavel(this, this.form.aux_lindigi4, 11, '-');
                                                                                                                        desabilitaCampos('F', 'LD', this.form);" maxlength="13"></td>
                                                                                                                <td width="100"><input name="aux_lindigi4" type="text" class="Campo" id="aux_lindigi4" style="width: 95px;" value="" onKeyPress="return validaNumero(event);" onKeyUp="formataLinhaDigitavel(this, this.form.btnOK, 11, '-');
                                                                                                                        desabilitaCampos('F', 'LD', this.form);" maxlength="13"></td>
                                                                                                                <td><input name="btnOK" type="button" class="botao_validar" id="btnOK" value="OK" onClick="valida_documento(this.form, 'F');"></td>						
                                                                                                            </tr>
                                                                                                        </table>
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td height="20" class="linkMenuAdmin">C&oacute;digo de Barras:</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td><input name="aux_cdbarras" type="text" class="Campo" id="aux_cdbarras" style="width: 285px;" value="" maxlength="44" onKeyPress="return validaNumero(event);" onKeyUp="desabilitaCampos('F', 'CB', this.form);onReadCodBarras(this.form, 'F');"></td>			
                                                                                                </tr>	
                                                                                                <tr>
                                                                                                    <td height="5" colspan="5"></td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td height="1" colspan="5" bgcolor="#999999"></td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td height="5" colspan="5"></td>
                                                                                                </tr>					
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                                            <tr>
                                                                                                                <td width="106" nowrap class="txtNormal">Valor do Documento: </td>
                                                                                                                <td width="115"><input name="aux_vlrdocum" type="text" class="Campo" id="aux_vlrdocum" style="width: 100px;" value="" readonly="yes"></td>
                                                                                                                <td><input name="btnLimpar" type="button" class="botao_validar" id="btnLimpar" value="Limpar" onClick="limparCampos(this.form, 'C');"></td>
                                                                                                            </tr>
                                                                                                        </table>
                                                                                                    </td>
                                                                                                </tr>						
                                                                                            </table>			
                                                                                        </form>		
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
