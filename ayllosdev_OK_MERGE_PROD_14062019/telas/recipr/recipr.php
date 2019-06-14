<?php
/*!
 * FONTE        : recipr.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : Marco/2016
 * OBJETIVO     : Mostrar rotina de acompanhamento de Reciprocidade.
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();
?>
<script type="text/javascript" src="../../telas/recipr/recipr.js"></script>
<table cellpadding="0" cellspacing="0" border="0" width="800">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">RECIPR - Acompanhamento Reciprocidade</td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),$('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>     
                    </td> 
                </tr>    
                <tr>
                    <td class="tdConteudoTela" align="center">	
                        <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td style="border: 1px solid #F4F3F0;">
                                    <table border="background-color: #F4F3F0;" cellspacing="0" cellpadding="0" >
                                        <tr>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="8" height="21" id="imgAbaEsq0"></td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0" class="txtNormalBold">Principal</td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="8" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <div id="divConteudoReciprocidade"></div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<script type="text/javascript">
    // Variveis globais
    glb_nrdconta = '<?php echo (int) $_POST['glb_nrdconta']; ?>';
    glb_nrconven = '<?php echo (int) $_POST['glb_nrconven']; ?>';
    glb_nmrotina = '<?php echo $_POST['glb_nmrotina']; ?>';

    // Busca os dados da tela
    acessaOpcaoAbaReciprocidade();
</script>