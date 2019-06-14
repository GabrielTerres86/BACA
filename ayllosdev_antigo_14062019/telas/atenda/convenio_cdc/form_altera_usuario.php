<?php
/*!
 * FONTE        : form_altera_usuario.php
 * CRIAÇÃO      :Diego Simas (AMcom)
 * DATA CRIAÇÃO : 26/05/2018
 * OBJETIVO     : Formulário para alterar o dados do usuario 
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	 
 
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
 
  $idcooperado_cdc = (isset($_POST['idcooperado_cdc'])) ? $_POST['idcooperado_cdc'] : 0  ;
  $idusuario = (isset($_POST['idusuario'])) ? $_POST['idusuario'] : 0  ;

  //Mensageria referente a situação de prejuízo
  $xml  = "";
  $xml .= "<Root>";
  $xml .= "  <Dados>";
  $xml .= "    <idcooperado_cdc>".$idcooperado_cdc."</idcooperado_cdc>";
  $xml .= "    <idusuario>".$idusuario."</idusuario>";
  $xml .= "  </Dados>";
  $xml .= "</Root>";

  $xmlResult = mensageria($xml, "TELA_ATENDA_CVNCDC", "CONSULTA_USUARIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
  $xmlObjeto = getObjectXML($xmlResult);	

  $param = $xmlObjeto->roottag->tags[0]->tags[0];

  if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',"controlaOperacao('');",false); 
  }else{  
    $senhaUsuario = getByTagName($param->tags,'senha');	    
    $tipo = getByTagName($param->tags,'tipo');	    
    $vinculo = getByTagName	($param->tags,'vinculo');	    
    $ativo = getByTagName($param->tags,'ativo');	    
    $bloqueio = getByTagName($param->tags,'bloqueio');
    $dsvinculo = getByTagName ($param->tags,'dsvinculo');	        
  }
  
?>
<form name="frmUsuario" id="frmUsuario" class="formulario">
  <input type="hidden" id="senhaUsuario" name="senhaUsuario" value="<?php echo $senhaUsuario; ?>">
  <fieldset style="padding: 5px;">    
		<legend style="margin-top: 10px; padding: 2px 10px 2px 10px">Alterar Usu&aacute;rio</legend>
		<label for="senha" class="txtNormalBold" style="width: 70px;">Senha:</label>
		<input type="text" id="senha" name="senha" value="" class="Campo" style="width: 220px; text-align: right;" maxlength="100"/>    
    <br>
    <br>
		<label for="tipo" class="txtNormalBold" style="width: 70px;">Tipo:</label>		    
    <select name="tipo" class="Campo" id="tipo" style="width: 160px;">
			<option value="0" <?php if ($tipo == 0) { echo "selected"; } ?> >Vendedor</option>
		  <option value="1" <?php if ($tipo == 1) { echo "selected"; } ?> >Administrador</option>
		</select>        
    <br>
    <br>
		<label for="cdvinculo" class="txtNormalBold" style="width: 70px;">V&iacute;nculo:</label>
		<input type="text" id="cdvinculo" name="cdvinculo" value="<?php if ($vinculo > 0) { echo $vinculo; } ?>" class="Campo inteiro" style="width: 60px; text-align: right;" maxlength="10"/>
    <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" onclick="controlaPesquisaVinculo();"></a>		
		<input type="text" id="dsvinculo" name="dsvinculo" value="<?php echo $dsvinculo; ?>" style="width: 250px;" class="campo" readonly />
    <br>
    <br>
		<label for="ativo" class="txtNormalBold" style="width: 70px;">Ativo:</label>
		<select name="ativo" class="Campo" id="ativo" style="width: 70px;">
			<option value="0" <?php if ($ativo == 0) { echo "selected"; } ?> >N&atilde;o</option>
		  <option value="1" <?php if ($ativo == 1) { echo "selected"; } ?> >Sim</option>
		</select>     
    <br>
    <br>
		<label for="bloqueio" class="txtNormalBold" style="width: 70px;">Bloqueio:</label>
		<select name="bloqueio" class="Campo" id="bloqueio" style="width: 70px;">
			<option value="0" <?php if ($bloqueio == 0) { echo "selected"; } ?> >N&atilde;o</option>
		  <option value="1" <?php if ($bloqueio == 1) { echo "selected"; } ?> >Sim</option>
		</select>   
	</fieldset>	
</form>
<div id="divBotoes">	
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="acessaOpcaoAba('U',3);" />
	<input type="image" id="btConcluir" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="alteraUsuario(); return false;" />
</div>
<script>
	formataUsuario();
</script>