<?php
    /*
     * FONTE        : form_motivo.php
     * CRIAÇÃO      : Lombardi
     * DATA CRIAÇÃO : 23/08/2016
     * OBJETIVO     : Tela de motivo da alteração da situação do gravame.
     * --------------
     * ALTERAÇÕES   : 
     * --------------
     */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');

    $idseqbem = (isset($_POST['idseqbem'])) ? $_POST['idseqbem'] : '' ;
	$tpctrpro = (isset($_POST['tpctrpro'])) ? $_POST['tpctrpro'] : '' ;
	$dssitgrv = (isset($_POST['dssitgrv'])) ? $_POST['dssitgrv'] : '' ;
	
?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table cellpadding="0" cellspacing="0" border="0" width="400">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">ALTERA&Ccedil;&Atilde;O DE SITUA&Ccedil;&Atilde;O</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>        
						</table>
					</td>        
				</tr>        
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%"  border="0" cellspacing="0" cellpadding="0" align="center">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<form id="frmMotivo" name="frmRegra" class="formulario">
										<fieldset>
											<legend>MOTIVO</legend>
											<textarea name="dsmotivo" id="dsmotivo" cols="5" maxlength="2000" ></textarea>
										</fieldset>
									</form>
									<a href="#" class="botao" id="btVoltarMotivo" >Voltar</a>
									<a href="#" class="botao" id="btContinuarMotivo" >Continuar</a>
								</td>
							</tr>
						</table>
					</td>        
				</tr>   
			</table>				
		</td>
	</tr>
</table>