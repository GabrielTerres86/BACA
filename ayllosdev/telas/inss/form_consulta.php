<?php
/*****************************************************************
	Fonte        : form_consulta.php					Última alteração: 07/01/2019
  Criação      : Adriano
  Data criação : Maio/2013
  Objetivo     : Mostra o form de consulta da tela INSS
  --------------
  Alterações   : 10/03/2015 - Ajuste referente ao Histórico cadastral
                              (Adriano - Softdesk 261226).
							  
				 01/09/2015 - Mudança no layout:
						      Aumento do tamanho da tela para inclusao de novos campos.
							  Inseridos campos "Data de nascimento", "Descrição do benefício".
							  Projeto 255 - INSS (Lombardi)

					03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)


					26/06/2017 - Ajuste para rotina ser chamada através da tela ATENDA > Produtos (Jonata - RKAM - P364).

					07/01/2019 - Inclusão das rotinas para uso do serviço de "Reenvio cadastral"
			                    (Jonata - Mouts - SCTASK0030602).

  --------------
 ****************************************************************/ 
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
 
?>

<form id="frmConsulta" name="frmConsulta" class="formulario" style="display:none">	
	
	<label for="razaosoc">Cooperativa:</label>
	<input id="razaosoc" name="razaosoc" type="text" value="<?echo getByTagName($registro->tags,'razaosoc');?>"></input>
	
	<br />
	
	<label for="cdorgins">&Oacute;rg&atilde;o pagador:</label>
	<input id="cdorgins" name="cdorgins" type="text" value="<?echo getByTagName($registro->tags,'cdorgins');?>"></input>
	
	<label for="nmresage">PA:</label>
	<input id="nmresage" name="nmresage" type="text" value="<?echo getByTagName($registro->tags,'nmresage');?>"></input>
	
	<br style="clear:both">
	
	<hr style="background-color: rgb(102, 102, 102); height: 1px; margin: 3px 0pt;">

	<label for="nrdconta">Conta/dv:</label>
	<input id="nrdconta" name="nrdconta" type="text" value="<?echo formataContaDV(getByTagName($registro->tags,'nrdconta'));?>"></input>
	
	<label for="nmtitula">Titular:</label>
	<input id="nmtitula" name="nmtitula" type="text" value="<?echo getByTagName($registro->tags,'idseqttl').' - '.getByTagName($registro->tags,'nmextttl');?>"></input>
	
	<br />
	
	<label for="dtcompvi">&Uacute;ltima comprova&ccedil;&atilde;o de vida:</label>
	<input id="dtcompvi" name="dtcompvi" type="text" value="<?echo getByTagName($registro->tags,'dtcompvi');?>"></input>
	
	<label for="dtutirec">Dia &uacute;til para recebimento:</label>
	<input id="dtutirec" name="dtutirec" type="text" value="<?echo getByTagName($registro->tags,'dtutirec');?>"></input>
	
	<br />
	
	<label for="dtdcadas">Data do cadastramento:</label>
	<input id="dtdcadas" name="dtdcadas" value="<?echo getByTagName($registro->tags,'dtdcadas');?>"></input>
	
	<label for="dscsitua">Situa&ccedil;&atilde;o:</label>
	<input id="dscsitua" name="dscsitua" value="<?echo getByTagName($registro->tags,'dscsitua');?>"></input>
		
	<br />
	
	<label for="dtdnasci">Data de nascimento:</label>
	<input id="dtdnasci" name="dtdnasci" value="<?echo getByTagName($registro->tags,'dtdnasci');?>"></input>
	
	<label for="stacadas">Status do cadastro:</label>
	<input id="stacadas" name="stacadas" value="<?echo getByTagName($registro->tags,'stacadas');?>"></input>
	
	<br />
	
	<label for="dscespec">Descri&ccedil;&atilde;o do benefic&iacute;o:</label>
	<input id="dscespec" name="stacadas" value="<?echo getByTagName($registro->tags,'dscespec');?>"></input>
	
	<br />
	
	<br style="clear:both" />
	
	<fieldset id="fsetInss" name="fsetInss" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend> Dados do INSS </legend>
		
		<label for="nrcpfcgc">C.P.F.:</label>
		<input id="nrcpfcgc" name="nrcpfcgc" type="text" value="<?echo getByTagName($registro->tags,'nrcpfcgc');?>"></input>
		
		<label for="nrdddtfc">Telefone:</label>
		<input id="nrdddtfc" name="nrdddtfc" type="text" value="<?echo getByTagName($registro->tags,'nrdddtfc');?>"></input>
		
		<label for="nrtelefo"></label>
		<input id="nrtelefo" name="nrtelefo" type="text"value="<?echo getByTagName($registro->tags,'nrtelefo');?>"></input>
		
		<br />
		
		<label for="dsendben">Endere&ccedil;o:</label>
		<input id="dsendben" name="dsendben" type="text" value="<?echo getByTagName($registro->tags,'dsendere');?>"></input>
		
		<label for="nrcepend">CEP:</label>
		<input id="nrcepend" name="nrcepend" type="text" value="<?echo formataCep(getByTagName($registro->tags,'nrcepend'));?>"></input>
		
		<br />
		
		<label for="nmbairro">Bairro:</label>
		<input id="nmbairro" name="nmbairro" type="text" value="<?echo getByTagName($registro->tags,'nmbairro');?>"></input>
				
		<br />
		
		<label for="nmcidade">Cidade:</label>
		<input id="nmcidade" name="nmcidade" type="text" value="<?echo getByTagName($registro->tags,'nmcidade');?>"></input>
		
		<label for="cdufende">U.F.:</label>
		<input id="cdufende" name="cdufende" type="text" value="<?echo getByTagName($registro->tags,'cdufende');?>"></input>
		
		<br />
		
	</fieldset>	
	
	<fieldset id="fsetProcurador" name="fsetProcurador" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend> Dados do Procurador </legend>
		
		<label for="nmprocur">Nome:</label>
		<input id="nmprocur" name="nmprocur" type="text" value="<?echo getByTagName($registro->tags,'nmprocur');?>"></input>
		
		<label for="nrdocpro">Documento:</label>
		<input id="nrdocpro" name="nrdocpro" type="text" value="<?echo getByTagName($registro->tags,'nrdocpro');?>"></input>
		
		<br /> 
		
		<label for="dtvalprc">Validade:</label>
		<input id="dtvalprc" name="dtvalprc" type="text" value="<?echo getByTagName($registro->tags,'resdesde');?>"></input>
		
		<br />
			
				
	</fieldset>		
		
	<input id="idbenefi" name="idbenefi" type="hidden" value="<?echo getByTagName($registro->tags,'idbenefi');?>"></input>
	<input id="cdagesic" name="cdagesic" type="hidden" value="<?echo getByTagName($registro->tags,'cdagesic');?>"></input>
	<input id="nmbenefi" name="nmbenefi" type="hidden" value="<?echo getByTagName($registro->tags,'nmbenefi');?>"></input>
	<input id="tpnrbene" name="tpnrbene" type="hidden" value="<?echo getByTagName($registro->tags,'tpnrbene');?>"></input>
	<input id="nrrecben" name="nrrecben" type="hidden" value="<?echo getByTagName($registro->tags,'nrrecben');?>"></input>
	<input id="tpdosexo" name="tpdosexo" type="hidden" value="<?echo getByTagName($registro->tags,'tpdosexo');?>"></input>
	<input id="nomdamae" name="nomdamae" type="hidden" value="<?echo getByTagName($registro->tags,'nomdamae');?>"></input>
	<input id="cdagepac" name="cdagepac" type="hidden" value="<?echo getByTagName($registro->tags,'cdagepac');?>"></input>
	<input id="copvalid" name="copvalid" type="hidden" value="<?echo getByTagName($registro->tags,'copvalid');?>"></input>
	
	<input id="idseqttl" name="idseqttl" type="hidden" value="<?echo getByTagName($registro->tags,'idseqttl');?>"></input>	
	<input id="nmextttl" name="nmextttl" type="hidden" value="<?echo getByTagName($registro->tags,'nmextttl');?>"></input>	
	<input id="nrcpfttl" name="nrcpfttl" type="hidden" value="<?echo getByTagName($registro->tags,'nrcpfttl');?>"></input>	
	<input id="dsendttl" name="dsendttl" type="hidden" value="<?echo getByTagName($registro->tags,'dsendttl');?>"></input>	
	<input id="nrendttl" name="nrendttl" type="hidden" value="<?echo getByTagName($registro->tags,'nrendttl');?>"></input>	
	<input id="nmbaittl" name="nmbaittl" type="hidden" value="<?echo getByTagName($registro->tags,'nmbaittl');?>"></input>	
	<input id="nrcepttl" name="nrcepttl" type="hidden" value="<?echo formataCep(getByTagName($registro->tags,'nrcepttl'));?>"></input>	
	<input id="nmcidttl" name="nmcidttl" type="hidden" value="<?echo getByTagName($registro->tags,'nmcidttl');?>"></input>	
	<input id="ufendttl" name="ufendttl" type="hidden" value="<?echo getByTagName($registro->tags,'ufendttl');?>"></input>	
	<input id="nrdddttl" name="nrdddttl" type="hidden" value="<?echo getByTagName($registro->tags,'nrdddttl');?>"></input>	
	<input id="nrtelttl" name="nrtelttl" type="hidden" value="<?echo getByTagName($registro->tags,'nrtelttl');?>"></input>	
		
</form>


<div id="divBotoesConsulta" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V4');">Voltar</a>
	
	<?if ($executandoProdutos != 'true') {
		
		for ($i = 0; $i < count($rotinas); $i++) {
		
		/*Habilita os botões abaixo apenas se a cooperativa do benefício for igual a cooperativa logada*/
		if($rotinas[$i] == "CONSULTA" && 
		   getByTagName($registro->tags,'copvalid') == 1){?>
						
			<a href="#" class="botao" id="btTrocaConta" onClick="acessaRotina('<?echo $rotinas[$i];?>','T');return false;" >Troca Conta</a>	
			<a href="#" class="botao" id="btCompravaVida" onClick="acessaRotina('<?echo $rotinas[$i];?>','C');return false;" >Comprova Vida</a>	
			<a href="#" class="botao" id="btAlteracaoCadastral" onClick="acessaRotina('<?echo $rotinas[$i];?>','A');return false;" >Altera Cadastro</a>	
			<a href="#" class="botao" id="btReenviarCadastro" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','reenviarCadastro(\'<?echo $cddopcao;?>\');','$(\'#btVoltar\',\'#divBotoesConsulta\').focus();','sim.gif','nao.gif');return false;" >Recadastramento</a> 
		<?}	
		}
	
	}?>
	
</div>