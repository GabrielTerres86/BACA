<?php
/*!
 * FONTE        : form_opcao_l.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Formulario de consulta dos LOGS de arquivos
 * --------------
 * ALTERAÇÕES   : 
 * --------------
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

<center>
<div id="divConsultaLog" name="divConsultaLog" style="width: 800px;">
	<form id="frmConsultaLog" name="frmConsultaLog" class="formulario" target="blank" method="POST">
		<fieldset>
			<legend>Log de movimenta&ccedil;&atilde;o dos arquivos de remessa</legend>
			<table width="100%" >
				<tr>
					<td>
						<label for="nrdconta">Conta:</label>
						<input type="text" id="nrdconta" name="nrdconta" alt="Informe a Conta/DV ou F7 para pesquisar e clique em OK ou ENTER para prosseguir."/>
						<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
						<a href="#" class="botao" id="btnOK1" >OK</a>
						<!--<label for="nmprimtl">Titular:</label> -->
						<input name="nmprimtl" id="nmprimtl" type="text" />						
					</td>					
				</tr>
				
				<tr>
					<td>
						<label for="dtiniper"><? echo utf8ToHtml('Per&iacute;odo:') ?></label>
						<input type="text" id="dtiniper" name="dtiniper" class="data" />
						<label for="dtfimper"><? echo utf8ToHtml('&agrave;') ?></label>
						<input type="text" id="dtfimper" name="dtfimper" class="data" />
						<div style="font-weight:bold;font-size:10px;margin-top:5px;margin-left:5px;">&nbsp;Periodo maximo de 7 dias.</div>
					</td>
				</tr>

				<tr>		
					<td>
						<label for="nmarquiv">Nome do Arquivo:</label>
						<input type="text" id="nmarquiv" name="nmarquiv" alt="Nome do arquivo"/>
					</td>
				</tr>
				
				<tr>		
					<td>
						<label for="nrremess">N&uacute;mero da Remessa:</label> 
						<input name="nrremess" id="nrremess" type="text" />											
					</td>
				</tr>
				
			</table>
		</fieldset>
		<br />
	</form>
</div>
</center>