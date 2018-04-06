<?
/* !
 * FONTE        : conta_corrente.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 12/05/2010 
 * OBJETIVO     : Mostra rotina de CONTA CORRENTE da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 29/10/2013 - Inserido a variavel cdcooper para fazer tratamento de cooperativa em tela. (James)
 *
 *                05/11/2013 - Removido a variavel cdcooper, pois foi removido a validacao em tela (James).
 *
 *                05/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 * 
 *                11/08/2015 - Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi).
 */
?>
<?
session_start();
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");
require_once("../../../includes/controla_secao.php");
require_once("../../../class/xmlfile.php");
isPostMethod();

// Se parâmetros necessários não foram informados
if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"]))
    exibirErro('error', 'Parâmetros incorretos.', 'Alerta - Ayllos', '');

$flgcadas = $_POST['flgcadas'];

// Verifica permissões de acessa a tela
if (($msgError = validaPermissao($_POST["nmdatela"],$_POST["nmrotina"],'@',false)) <> '') {
	$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
	exibirErro('error',$msgError,'Alerta - Ayllos',$metodo,true);
}

// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");

setVarSession("opcoesTela", $opcoesTela);

$qtOpcoesTela = count($opcoesTela);

// Carregas as opções da Rotina de Bens
$flgAcesso = (in_array('@', $glbvars['opcoesTela']));
$flgAlterar = (in_array('A', $glbvars['opcoesTela']));
$flgExcluir = (in_array('E', $glbvars['opcoesTela']));
$flgEncerrar = (in_array('E', $glbvars['opcoesTela']));
$flgSolITG = (in_array('S', $glbvars['opcoesTela']));
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo $nmrotina; ?></td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="encerraRotina(true);return false;" ><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=<? echo "acessaOpcaoAba(" . count($opcoesTela) . ",0,'" . $opcoesTela[0] . "');"; ?> class = "txtNormalBold">Principal</a></td>

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <div id="divConteudoOpcao"></div>
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
    // Declara os flags para as opções da Rotina de Bens
    var flgAlterar = '<? echo $flgAlterar; ?>';
    var flgExcluir = '<? echo $flgExcluir; ?>';
    var flgEncerrar = '<? echo $flgEncerrar; ?>';
    var flgSolITG = '<? echo $flgSolITG; ?>';
    var qtOpcoesTela = "<? echo $qtOpcoesTela; ?>";
    var flgcadas = '<? echo $flgcadas; ?>';

    exibeRotina(divRotina);

    /* nao precia para a nova tela CADMAT
    if (flgcadas == 'M' && inpessoa == 2) {
        controlaOperacao('CA');
    } else {*/
        acessaOpcaoAba("<? echo $qtOpcoesTela ?>", 0, "<? echo $opcoesTela[0]; ?>");
    //}



</script>