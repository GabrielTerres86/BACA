<?php
/* !
 * FONTE        : form_relatorio.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 29/03/2017
 * OBJETIVO     : Tela do formulario de impressao
 */
?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<table width="100%" cellpadding="0" cellspacing="0" border="0">
    <tr>
        <td align="center">
            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo utf8ToHtml('Imprimir Relat&oacute;rio') ?></td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina'));
                                                                        return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
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
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <div id="divConteudoOpcao">
										<form id="frmNomArquivo" name="frmNomArquivo" class="formulario" onSubmit="return false;" >
										</form>
										<div id="divBotoesEnviarEmail" style="margin-bottom: 15px; margin-top: 15px; text-align:center;" >
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
												<a href="#" class="botao" id="btImpComp" onClick="fechaRotina($('#divRotina')); imprimir_relatorio(0); return false;">Completo</a>
											<a href="#" class="botao" id="btImpCrit" onClick="fechaRotina($('#divRotina')); imprimir_relatorio(1); return false;">Cr&iacute;ticas</a>
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
