<?php
/* !
 * FONTE        : cartao_credito.php
 * CRIAÇÃO      : Guilherme (CECRED)
 * DATA CRIAÇÃO : Março/2008
 * OBJETIVO     : Mostrar rotina de Cartão de crédito da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [22/10/2010] Jorge           (CECRED) : Adaptação para Cartão PJ
 * 000: [23/03/2011] Jorge           (CECRED) : Adicionado condicao $opcoesTela[$i] == "Z", referente ao encerramente de cartao de credito.
 * 001: [05/05/2011] Rodolpho Telmo     (DB1) : Adaptação para Zoom Endereço e Avalista genérico
 * 000: [24/08/2011] Guilherme       (SUPERO) : Adicionado condicao $opcoesTela[$i] == "T", referente ao encerramente de cartao de credito.
 * 003: [17/07/2014] Daniel          (CECRED) : Adicionado condicao $opcoesTela[$i] == "D", referente ao upgrade de cartao de credito SD 179666.
 * 004: [29/07/2015] James           (CECRED) : Adicionado condicao $opcoesTela[$i] == "U".
 * 005: [25/07/2016] Evandro           (RKAM) : Adicionado classe (SetWindow) - necessaria para navegação com teclado
 */
?>

<?
session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();		

// Se parâmetros necessários não foram informados
if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
	exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','');	
}	

$inpessoa = $_POST['inpessoa'];
$labelRot = $_POST['labelRot'];	

// Carrega permissões do operador
include('../../../includes/carrega_permissoes.php');	

setVarSession("opcoesTela",$opcoesTela);
?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="850">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif">CART&Otilde;ES CR&Eacute;DITO</td>
                                <td width="12" id="tdTitTela" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true); return false;"><img src="<?echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>     
                    </td> 
                </tr>    
                <tr>
                    <td class="tdConteudoTela" align="center">	
                        <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <table border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <?php
                                            $contador = 0;
                                            $idPrincipal = 0;

                                            // Mostrar opções da rotina de capital no layer conforme permissão do operador
                                            for ($i = 0; $i < count($opcoesTela); $i++) {
                                                // Estas opções não aparecem na aba, são os botões
                                                // referentes a um cartão de crédito já existente
                                                if ($opcoesTela[$i] == "2" ||
                                                        $opcoesTela[$i] == "C" ||
                                                        $opcoesTela[$i] == "E" ||
                                                        $opcoesTela[$i] == "F" ||
                                                        $opcoesTela[$i] == "L" ||
                                                        $opcoesTela[$i] == "M" ||
                                                        $opcoesTela[$i] == "R" ||
                                                        $opcoesTela[$i] == "T" ||
                                                        $opcoesTela[$i] == "A" ||
                                                        $opcoesTela[$i] == "X" ||
                                                        $opcoesTela[$i] == "N" ||
                                                        $opcoesTela[$i] == "H" ||
                                                        $opcoesTela[$i] == "Z" ||
                                                        $opcoesTela[$i] == "D" ||
                                                        $opcoesTela[$i] == "O" ||
                                                        $opcoesTela[$i] == "B" ||
                                                        $opcoesTela[$i] == "S" ||
                                                        $opcoesTela[$i] == "G" ||
                                                        $opcoesTela[$i] == "U") {
                                                    continue;
                                                }

                                                switch ($opcoesTela[$i]) {
                                                    case "@": $nameOpcao = "Principal";
                                                        $idPrincipal = $i;
                                                        break;
                                                }
                                                $contador++;
                                                ?>
                                                <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq<?php echo $i; ?>"></td>
                                                <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen<?php echo $i; ?>"><a href="#" id="linkAba<?php echo $i; ?>" onClick="acessaOpcaoAba(<?php echo count($opcoesTela); ?>,<?php echo $i; ?>, '<?echo $opcoesTela[$i]; ?>'); return false;" class="txtNormalBold"><?echo $nameOpcao; ?></a></td>
                                                <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir<?php echo $i; ?>"></td>
                                                <td width="1"></td>
                                                <?php
                                            } // Fim do for
                                            ?>	
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <div id="divConteudoOpcao" style="border:1px; height:auto;">&nbsp;</div>
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
	
	mostraRotina();
	hideMsgAguardo();
 <?
	  if (in_array("@", $opcoesTela)) { // Se operador possuir permissão, executa opção Principal da rotina		
		echo "acessaOpcaoAba(".count($opcoesTela).",".$idPrincipal.",'".$opcoesTela[$idPrincipal]."');";
	} else { // Executa primeira opção da rotina que o operador tem permissão
		echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');";
	}
?>
</script>