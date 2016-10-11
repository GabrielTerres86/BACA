<?php
/*!
 * FONTE        : manter_pendencia.php
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : Junho/2016
 * OBJETIVO     : Mostrar tela de Manutenção de Seguros Sicredi - PENSEG
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();
?>
<table id="telaInicial" id="telaInicial" cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">
            <table cellpadding="0" cellspacing="0" border="0" width="420">
               <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0" >
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"> Manuten&ccedil;&atilde;o de Pend&ecirc;ncias SICREDI </td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>
                    </td>
               </tr>
               <tr >
                    <td class="tdConteudoTela" align="center">
                      <table width="480" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px">
                                <div id="divConteudoOpcao">
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
