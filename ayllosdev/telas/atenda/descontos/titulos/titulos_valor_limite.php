<?php
/*!
 * FONTE        : titulos_valor_limite.php
 * CRIAÇÃO      : Leonardo
 * DATA CRIAÇÃO : 13/03/2018
 * OBJETIVO     : Tela para renovação do valor limite de desconto de titulo
 * ALTERAÇÕES   : 
 * --------------
 * 001: [16/03/2018] Leonardo Oliveira (GFT): Novos campos 'linha de crédito', 'descrição da linha', e uso da flgstlcr para verificar se a linha é bloqueada
 * 002: [22/03/2018] Leonardo Oliveira (GFT): Esconder o botão de renovação quando a linha de crédito for bloqueada.
 *
 */	
?>
 
<?php
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
    require_once('../../../../includes/controla_secao.php');
	require_once("../../../../class/xmlfile.php");

	setVarSession("nmrotina","DSC TITS - LIMITE");

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"R",false)) <> '') {
		exibirErro("error",$msgError,"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))",true);
	}
	
	$vllimite = (isset($_POST['vllimite'])) ? $_POST['vllimite'] : 0;
	$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0;
	$cddlinha = (isset($_POST['cddlinha'])) ? $_POST['cddlinha'] : 0;
	$flgstlcr = (isset($_POST['flgstlcr'])) ? $_POST['flgstlcr'] : 0;
	$dsdlinha = (isset($_POST['dsdlinha'])) ? $_POST['dsdlinha'] : 0;
?>
<div id="divValorLimite">
	<div class="divRegistros">
		<form id="frmReLimite" onsubmit="return false;">
			<fieldset>

			<input type="hidden" id="nrctrlim" name="nrctrlim" value="<? echo $nrctrlim; ?>" />
			<input type="hidden" id="flgstlcr" name="flgstlcr" value="<? echo $flgstlcr; ?>" />

			<?php if ($flgstlcr == 0){ ?>

				<label for="cddlinha"><? echo utf8ToHtml('Linha de Crédito: ') ?></label>
				<input name="cddlinha" id="cddlinha" type="text" value="<? echo $cddlinha ?>"/>
				<a>
					<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif">
				</a>

				<br/>

				<label for="dsdlinha"></label>
				<input name="dsdlinha" id="dsdlinha" type="text" value="<? echo $dsdlinha ?>" />

				<br />

			<?php } else { ?>

				<input type="hidden" id="cddlinha" name="cddlinha" value="<? echo $cddlinha; ?>" />

			<?php }?>
			
			<label for="vllimite"> Valor Limite: </label>
			<input type="text" id="vllimite" name="vllimite" value="<? echo $vllimite; ?>" />

			</fieldset>
		</form>			    
					
	</div>
</div>
<div id="divBotoes" class="divBotoes">
	

<input 
	type="button" 
	class="botao" 
	value="Voltar"  
	id="btnVoltar" 
	name="btnVoltar" 
	onClick="voltar();"/>
<?php if($flgstlcr != 0){?>
<input 
	type="button" 
	class="botao" 
	value="Renovar"
	id="btRenovar"
	name="btRenovar"
	onClick="executarRenovaValorLimite();"/>
	<?php } ?>
	
</div>

<script type="text/javascript">
	//Metodo de formatação 'formataValorLimite'

	dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

	// Muda o título da tela
	$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - VALOR LIMITE");

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	function executarRenovaValorLimite(){
		var vllimite = $('#vllimite','#frmReLimite').val();
    	var nrctrlim = $('#nrctrlim','#frmReLimite').val();
    	var cddlinha = $('#cddlinha','#frmReLimite').val();
    	renovaValorLimite(vllimite, nrctrlim, cddlinha);
		fecharRotinaGenerico('TITULOS');
        return false;
	}

	function voltar(){
		fecharRotinaGenerico('TITULOS');
		return false;
	}
	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));

</script> 