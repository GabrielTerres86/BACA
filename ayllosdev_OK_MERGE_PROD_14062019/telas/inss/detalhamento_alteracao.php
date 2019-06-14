<?
/*!
 * FONTE        : detalhamento_tarifa.php
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 13/11/2015
 * OBJETIVO     : Tela do formulario de detalhamento de tarifas
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	
  require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
  
  $dtmvtolt = (isset($_POST["dtmvtolt"])) ? $_POST["dtmvtolt"] : "";
  $hrmvtolt = (isset($_POST["hrmvtolt"])) ? $_POST["hrmvtolt"] : "";
  $nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
  $nmdconta = (isset($_POST["nmdconta"])) ? $_POST["nmdconta"] : "";
  $nrrecben = (isset($_POST["nrrecben"])) ? $_POST["nrrecben"] : "";
  $historic = (isset($_POST["historic"])) ? $_POST["historic"] : "";
  $operador = (isset($_POST["operador"])) ? $_POST["operador"] : "";
  
?>

<table width="100%" id='telaDetalhamento' cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table width="100%" border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Detalhamento de Tarifas') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                  <br/>
									<div id="divConteudoOpcao" >
                  <div id="divDetalhesLog" style="width: 100%; display: block;">
                    <form action="" method="post" name="frmDetalheLog" id="frmDetalheLog">
                      <table border="0" cellpadding="0" cellspacing="0">
                        <tr>
                          <td width="55" class="txtNormalBold" height="23" align="right">Data:&nbsp;</td>
                          <td width="72" class="txtNormal"><input name="det_dtmvtolt" type="text" class="campo" id="det_dtmvtolt" style="width: 72px;" readonly value="<? echo $dtmvtolt; ?>"></td>
                        
                          <td width="90" class="txtNormalBold" height="23" align="right">NB:&nbsp;</td>
                          <td width="100" class="txtNormal"><input name="det_nrrecben" type="text" class="campo" id="det_nrrecben" style="width: 100px;" readonly value="<? echo $nrrecben; ?>"></td>
                          
                          <td width="110" class="txtNormalBold" height="23" align="right">Conta/dv:&nbsp;</td>
                          <td width="73" class="txtNormal"><input name="det_nrdconta" type="text" class="campo" id="det_nrdconta" style="width: 73px;" readonly value="<? echo $nrdconta; ?>"></td>
                        </tr>
                        <tr>
                          <td width="55" class="txtNormalBold" height="23" align="right">Hora:&nbsp;</td>
                          <td width="72" class="txtNormal"><input name="det_hrmvtolt" type="text" class="campo" id="det_hrmvtolt" style="width: 72px;" readonly value="<? echo $hrmvtolt; ?>"></td>
                          
                          <td width="90" class="txtNormalBold" height="23" align="right">Operador:&nbsp;</td>
                          <td width="100" class="txtNormal"><input name="det_operador" type="text" class="campo" id="det_operador" style="width: 100px;" readonly value="<? echo $operador; ?>"></td>		
                        </tr>
                        <tr>
                          <td width="55" class="txtNormalBold" height="23" align="right">Nome:&nbsp;</td>
                          <td colspan="5" class="txtNormal"><input name="det_nmdconta" type="text" class="campo" id="det_nmdconta" style="width: 450px;" readonly value="<? echo $nmdconta; ?>"></td>
                        </tr>
                        <tr>
                          <td class="txtNormalBold" height="23" align="right" id="tdMotivoDetalhe" valign="top">Altera&ccedil;&atilde;o:&nbsp;</td>
                          <td colspan="5" class="txtNormal"><textarea name="det_historic" class="campo" id="det_historic" style="width: 450px; height: 33px; resize: none;" style="overflow: hidden;" readonly><? echo $historic; ?></textarea></td>
                        </tr>
                        <tr>
                          <td colspan="6" height="10"></td>
                        </tr>
                        <tr>
                        <td colspan="6" align="center"><a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a></td>
                        </tr>
                      </table>
                    </form>
                  </div>
                  <br/>
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