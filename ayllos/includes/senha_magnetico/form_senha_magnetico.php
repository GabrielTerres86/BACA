<? 
/***************************************************************************************
 * FONTE        : form_senha_magnetico.php				Última alteração: --/--/----
 * CRIAÇÃO      : Jonata
 * DATA CRIAÇÃO : Marco/2017
 * OBJETIVO     : Solicita senha do cartão magnético do cooperado
 
   Alterações   : 
  
 
 **************************************************************************************/
?>
 
<?
	session_start();
		
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	
	isPostMethod();		
		
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');
			
	setVarSession("opcoesRotina",$opcoesTela);
  
	$retorno  = (isset($_POST['retorno']))  ? $_POST['retorno']  : "";
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";	

	// Guardo os parâmetos do POST em variáveis	
	$nmdatela = (isset($_POST['nmdatela'])) ? $_POST['nmdatela'] : '';
	$nmrotina = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : '';
	$validainternet = (isset($_POST['validainternet'])) ? $_POST['validainternet'] : '';
  
    $session = session_id();	    
    
	
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?echo utf8ToHtml('Senha') ;?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico')); blockBackground(parseInt($('#divRotina').css('z-index'))); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">							
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="acessaOpcaoAba(4,0,'@')" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <form id="frmSenha" name="frmSenha" class="formulario" onsubmit="return false;">
										<fieldset>
											<legend><? echo utf8ToHtml('Disponibilize o PinPad para o cooperado') ?></legend>
											
											<div id="divSolicitaSenhaMagnetico" style=";margin-top:1px; margin-bottom :0px;" align="center">
												<br />
												<label for="cddsenha">Senha:</label>
												<input name="cddsenha" id="cddsenha" type="password" maxlength="6" value=""/>
												<input id="retorno"  type="hidden" name="retorno"  value="<?echo $retorno?>"></input>	
												<input id="nrdconta" type="hidden" name="nrdconta" value="<?echo $nrdconta?>"></input>	
												<input id="validainternet" type="hidden" name="validainternet" value="<?echo $validainternet?>"></input>	
												</br>
												</br>
											</div>
										</fieldset>	
										</br>
									</form>
                                    <div id='divBotoesSenhaMagnetico'>
                                        <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico')); blockBackground(parseInt($('#divRotina').css('z-index'))); return false;">Cancelar</a>
                                        <a href="#" class="botao" id="btValidar" onClick="validaSenhaMagnetico();fechaRotina($('#divUsoGenerico')); blockBackground(parseInt($('#divRotina').css('z-index'))); return false;" >Concluir</a> 
                                        <br />
                                        <br />
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
<script>
  
  $('#cddsenha','#divSolicitaSenhaMagnetico').unbind('keypress').bind('keypress', function (e){
	
		if ( divError.css('display') == 'block' ) { return false; }		
		
		//Enter ou TAB
		if(e.keyCode == 13 || e.keyCode == 9){
		
			validaSenhaMagnetico();
            fechaRotina($('#divUsoGenerico'));
			blockBackground(parseInt($('#divRotina').css('z-index'))); 
			return false;
			
		}
					
	});
</script>
