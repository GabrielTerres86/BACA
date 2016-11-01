<?php 
/***************************************************************

  Fonte: titulares.php
  Autor: Gabriel
  Data : Janeiro/2011           Ultima atualizacao: 09/05/2013
  
  Objetivo: Mostrar os titulares da conta na opcao de habilitacao.
  
  Alteracoes: 14/07/2011 - Alterado para layout padrão (Gabriel - DB1).
 *  
 *  	     09/05/2013 - Retirado campo Vlr.Max. do boleto. (Jorge)
****************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

$cddopcao        = trim($_POST["cddopcao"]);
$titulares       = $_POST["titulares"];

?>

<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td align="center" valign="top">						
								
			<form class="formulario">
				<fieldset>
					<legend>Titulares</legend>
					
					<table cellpadding="0" cellspacing="1" border="0">
					
						<tr height="10">							
						</tr>
									
						<tr>
							<td colspan="4" >					
								<table border="1" cellpadding="1" cellspacing="5">																
									<tr style="background-color: #F4D0C9;">									
										<td width="50"  class="txtNormalBold" align="left">Titular</td>
										<td width="360" class="txtNormalBold" align="left">Nome</td>
									</tr>
								</table>
							</td>			
						</tr>							
						<tr>
							<td colspan="10"  >	
							
								<div id="divTit" style="overflow-y: scroll; height: 100px;" >	
								
								<table border="1" cellpadding="1" cellspacing="5"   >														
									<? 																
									
									$titular = explode("|",$titulares);		
									$num_tit = 0;		
																								
									foreach($titular as $tit) { // Para cada Titular 	
									   
										$dsdregis = strtok($tit,";");									 
										$contador = 0;	
										$num_tit++;
												
										while ($dsdregis) {	// Pegar tit, nome e valor 																
										   switch ($contador) {
												case 0: $idseqttl = $dsdregis; break;
												case 1: $nmextttl = $dsdregis; break; 
										   }																	
										   $contador++;	
										   $dsdregis = strtok(";");  									   
										}																																																																							
									?>							
									<tr id="titular" <?php echo ""; ?> >		
										<td class="campoTelaSemBorda" style= "width:  40; font-size:10px; text-align:right;"> <?php echo $idseqttl; ?> </td> 
										<td class="campoTelaSemBorda" style= "width: 330; font-size:10px; text-align:left;">  <?php echo $nmextttl; ?> </td> 
									</tr>								
									<? } ?>	
												
								</table>
								
								</div>
							</td>								
						</tr>
					</table>
					
				</fieldset>
			</form>
			<div id="divBotoes">
				<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="$('#divOpcaoConsulta').css('display','block');$('#divTitular').css('display','none');return false;" />
			</div>
		</td>
	</tr>
</table>	


<script type="text/javascript">

$("#divOpcaoConsulta").css("display","none");
$("#divTitular").css("display","block");

blockBackground(parseInt($("#divRotina").css("z-index")));

</script>
