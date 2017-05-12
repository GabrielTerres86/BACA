<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 04/05/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Responsável Legal da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 * 				  24/04/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *				  08/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *				  13/07/2016 - Correcao do acesso a variavel tppessoa do array $_POST. SD 479874. (Carlos R.)
 *                08/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 *                25/04/2017 - Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 */

    session_start();
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once("../controla_secao.php");	
	require_once("../../class/xmlfile.php");
	isPostMethod();		
	
	$cddopcao = $_POST['cddopcao_rsp'] == '' ? 'C'  : $_POST['cddopcao_rsp'];	
	$op       = $_POST['cddopcao_rsp'] == '' ? '@'  : $_POST['cddopcao_rsp'];

	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','fechaRotina(divRotina)',false);
		
	// Verifica se o número da conta e o titular foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]))  exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	
	// Guardo o número da conta e titular em variáveis
	$nrdconta = $_POST["nrdconta"]     == "" ? 0        : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"]     == "" ? 0    	: $_POST["idseqttl"];
	$nrcpfcto = $_POST["nrcpfcto"]     == "" ? 0   	    : $_POST["nrcpfcto"];
	$nrdctato = $_POST["nrdctato_rsp"] == "" ? 0        : $_POST["nrdctato_rsp"];	
	$nrdrowid = $_POST["nrdrowid_rsp"] == "" ? 0        : $_POST["nrdrowid_rsp"];	
	$operacao = $_POST["operacao_rsp"] == "" ? "CT"     : $_POST["operacao_rsp"];
	$cpfprocu = $_POST["cpfprocu"]     == "" ? 0        : $_POST["cpfprocu"];
	$nmrotina = $_POST["nmrotina"]     == "" ? 0        : $_POST["nmrotina"];
	$dtdenasc = $_POST["dtdenasc"]     == "" ? "?"  	: $_POST["dtdenasc"];
	$cdhabmen = $_POST["cdhabmen"]     == "" ? 0   	    : $_POST["cdhabmen"];
	$ope_rotinaant = $_POST["ope_rotinaant"] == "" ? "" : $_POST["ope_rotinaant"];
	$permalte = $_POST["permalte"]           == "" ? "" : $_POST["permalte"];
	$tppessoa = ( isset($_POST["tppessoa"]) ) ? $_POST["tppessoa"] : 0;
	$nmdatela = $_POST["nmdatela"]           == "" ? '' : $_POST["nmdatela"];
	$flgcadas = $_POST["flgcadas"]           == "" ? '' : $_POST["flgcadas"];
	
	
	if ( $operacao == 'TI' && $nmrotina == "Responsavel Legal") { 
	
		include('formulario_responsavel_legal.php'); 
		
		?>
		<script type="text/javascript">
		
			var operacao_rsp = '<? echo $operacao; ?>';
			controlaLayoutResp(operacao_rsp);
			
		</script>
		<?
		
		exit(); 
		
	}
		
		
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Ayllos','fechaRotina(divRotina)',false);

			
	if( ($nmrotina != "Identificacao" && $tppessoa != 1 )  || $operacao != "TE"){
	
		// Monta o xml de requisição
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Cabecalho>";
		$xml .= "		<Bo>b1wgen0072.p</Bo>";
		$xml .= "		<Proc>busca_dados</Proc>";
		$xml .= "	</Cabecalho>";
		$xml .= "	<Dados>";
		$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";   
		$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";   
		$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";   
		$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
		$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";               
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";               
		$xml .= "		<nrdctato>".$nrdctato."</nrdctato>";               
		$xml .= "		<nrdrowid>".$nrdrowid."</nrdrowid>";               
		$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";               
		$xml .= "		<nmrotina>".$nmrotina."</nmrotina>";  
		$xml .= "		<nrcpfcto>".$nrcpfcto."</nrcpfcto>";               
		$xml .= "		<cpfprocu>".$cpfprocu."</cpfprocu>";   
		$xml .= "		<permalte>".$permalte."</permalte>";   
		$xml .= "		<dtdenasc>".$dtdenasc."</dtdenasc>";   
		$xml .= "		<cdhabmen>".$cdhabmen."</cdhabmen>";   
		$xml .= "	</Dados>";
		$xml .= "</Root>";	
		
		$xmlResult = getDataXML($xml);
		$xmlObjeto = getObjectXML($xmlResult);	
		$registros = $xmlObjeto->roottag->tags[0]->tags;		
		
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){ 
			if( $cddopcao == 'I' ){
				exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaOperacaoResp(\'TI\')',false);
			}else{
				exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
			}
		}
		
		$menorida = $xmlObjeto->roottag->tags[0]->attributes['MENORIDA'];
		
		//Verifico se conta é titular em outra conta. Se atributo vier preenchido, muda operação para 'SC' => Somente Consulta
		$msgConta = trim($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']);
		if( $msgConta != '' ) {
			$operacao = ( $operacao != 'CF' ) ? 'SC' : $operacao;
		}
		
	}
		 		 
		
?>
<script type="text/javascript">
		
	$('#divOpcoesDaOpcao2').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
	
	
	if( '<? echo $nmrotina; ?>' == "Identificacao" 			  || 
		'<? echo $nmrotina; ?>' == "Representante/Procurador" ||
		'<? echo $nmrotina; ?>' == "MATRIC"){
			
		cooperativa = <? echo $glbvars["cdcooper"]; ?>;
				
		if( ('<? echo $operacao; ?>' == "CT"   || 
			 '<? echo $operacao; ?>' == "CF"   ||
			 '<? echo $operacao; ?>' == "SC"   ||
			 '<? echo $operacao; ?>' == "AV"   ||
			 '<? echo $operacao; ?>' == "IV" ) &&
			 criaTabela == 'CT' ){
						 
			arrayFilhos = new Array();
			
			<? for($i=0; $i<count($registros); $i++) {?>
			
				var regFilho<? echo $i; ?> = new Object(); 
								
				regFilho<? echo $i; ?>['cddctato'] = '<? echo getByTagName($registros[$i]->tags,'nrdconta'); ?>';
				regFilho<? echo $i; ?>['nrdrowid'] = '<? echo getByTagName($registros[$i]->tags,'nrdrowid'); ?>';
				regFilho<? echo $i; ?>['cdcooper'] = '<? echo getByTagName($registros[$i]->tags,'cdcooper'); ?>';
				regFilho<? echo $i; ?>['nrctamen'] = '<? echo getByTagName($registros[$i]->tags,'nrctamen'); ?>';
				regFilho<? echo $i; ?>['nrcpfmen'] = '<? echo getByTagName($registros[$i]->tags,'nrcpfmen'); ?>';
				regFilho<? echo $i; ?>['idseqmen'] = '<? echo getByTagName($registros[$i]->tags,'idseqmen'); ?>';
				regFilho<? echo $i; ?>['nrdconta'] = '<? echo getByTagName($registros[$i]->tags,'nrdconta'); ?>';
				regFilho<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($registros[$i]->tags,'nrcpfcgc'); ?>';
				regFilho<? echo $i; ?>['nmrespon'] = '<? echo stringTabela(getByTagName($registros[$i]->tags,'nmrespon'),33,'maiuscula') ?>';
				regFilho<? echo $i; ?>['nridenti'] = '<? echo getByTagName($registros[$i]->tags,'nridenti'); ?>';
				regFilho<? echo $i; ?>['tpdeiden'] = '<? echo getByTagName($registros[$i]->tags,'tpdeiden'); ?>';				
				regFilho<? echo $i; ?>['dsorgemi'] = '<? echo getByTagName($registros[$i]->tags,'dsorgemi'); ?>';				
				regFilho<? echo $i; ?>['cdufiden'] = '<? echo getByTagName($registros[$i]->tags,'cdufiden'); ?>';				
				regFilho<? echo $i; ?>['dtemiden'] = '<? echo getByTagName($registros[$i]->tags,'dtemiden'); ?>';				
				regFilho<? echo $i; ?>['dtnascin'] = '<? echo getByTagName($registros[$i]->tags,'dtnascin'); ?>';				
				regFilho<? echo $i; ?>['cddosexo'] = '<? echo getByTagName($registros[$i]->tags,'cddosexo'); ?>';				
				regFilho<? echo $i; ?>['cdestciv'] = '<? echo getByTagName($registros[$i]->tags,'cdestciv'); ?>';
				regFilho<? echo $i; ?>['dsnacion'] = '<? echo getByTagName($registros[$i]->tags,'dsnacion'); ?>';			
                regFilho<? echo $i; ?>['cdnacion'] = '<? echo getByTagName($registros[$i]->tags,'cdnacion'); ?>';			
				regFilho<? echo $i; ?>['dsnatura'] = '<? echo getByTagName($registros[$i]->tags,'dsnatura'); ?>';
				regFilho<? echo $i; ?>['cdcepres'] = '<? echo getByTagName($registros[$i]->tags,'cdcepres'); ?>';
				regFilho<? echo $i; ?>['dsendres'] = '<? echo getByTagName($registros[$i]->tags,'dsendres'); ?>';
				regFilho<? echo $i; ?>['nrendres'] = '<? echo getByTagName($registros[$i]->tags,'nrendres'); ?>';
				regFilho<? echo $i; ?>['dscomres'] = '<? echo getByTagName($registros[$i]->tags,'dscomres'); ?>';
				regFilho<? echo $i; ?>['dsbaires'] = '<? echo getByTagName($registros[$i]->tags,'dsbaires'); ?>';
				regFilho<? echo $i; ?>['nrcxpost'] = '<? echo getByTagName($registros[$i]->tags,'nrcxpost'); ?>';
				regFilho<? echo $i; ?>['dscidres'] = '<? echo getByTagName($registros[$i]->tags,'dscidres'); ?>';
				regFilho<? echo $i; ?>['dsdufres'] = '<? echo getByTagName($registros[$i]->tags,'dsdufres'); ?>';
				regFilho<? echo $i; ?>['nmpairsp'] = '<? echo getByTagName($registros[$i]->tags,'nmpairsp'); ?>';
				regFilho<? echo $i; ?>['nmmaersp'] = '<? echo getByTagName($registros[$i]->tags,'nmmaersp'); ?>';
				regFilho<? echo $i; ?>['cdrlcrsp'] = '<? echo getByTagName($registros[$i]->tags,'cdrlcrsp'); ?>';
					
				regFilho<? echo $i; ?>['cddopcao'] = '<? echo getByTagName($registros[$i]->tags,'cddopcao'); ?>';				
				regFilho<? echo $i; ?>['deletado'] = false;				
				arrayFilhos[<? echo $i; ?>] = regFilho<? echo $i; ?>;
				
				
			<?}?> 
	
		} 
		
	}
		
	
</script> 
<?	
		
	// Se estiver alterando, chamar o formulario de alteracao
	if (in_array($operacao,array('TC','TA','TI','TB','TE','CF'))){
	
		if($nmrotina == "Responsavel Legal"	     	 || 
		  (($nmrotina == "Identificacao" 			 ||
  		    $nmrotina == "Representante/Procurador"  ||
			$nmrotina == "MATRIC") 		  			 && 
		   ($operacao == "TB" 				         ||
 		    $operacao == "TI" 						 ))) {

			$frm_nrdconta = getByTagName($registros[0]->tags,'nrdconta');
			$frm_nrcpfcgc = getByTagName($registros[0]->tags,'nrcpfcgc');
			$frm_nmrespon = getByTagName($registros[0]->tags,'nmrespon');
			$frm_dtnascin = getByTagName($registros[0]->tags,'dtnascin');
			$frm_tpdeiden = getByTagName($registros[0]->tags,'tpdeiden');
			$frm_nridenti = getByTagName($registros[0]->tags,'nridenti');
			$frm_dsorgemi = getByTagName($registros[0]->tags,'dsorgemi');
			$frm_cdufiden = getByTagName($registros[0]->tags,'cdufiden');
			$frm_dtemiden = getByTagName($registros[0]->tags,'dtemiden');
			$frm_cdestciv = getByTagName($registros[0]->tags,'cdestciv');
			$frm_cddosexo = getByTagName($registros[0]->tags,'cddosexo');
			$frm_dsnacion = getByTagName($registros[0]->tags,'dsnacion');
            $frm_cdnacion = getByTagName($registros[0]->tags,'cdnacion');
			$frm_dsnatura = getByTagName($registros[0]->tags,'dsnatura');
			$frm_cdcepres = getByTagName($registros[0]->tags,'cdcepres');
			$frm_dsendres = getByTagName($registros[0]->tags,'dsendres');
			$frm_nrendres = getByTagName($registros[0]->tags,'nrendres');
			$frm_dscomres = getByTagName($registros[0]->tags,'dscomres');
			$frm_nrcxpost = getByTagName($registros[0]->tags,'nrcxpost');
			$frm_dsbaires = getByTagName($registros[0]->tags,'dsbaires');
			$frm_dsdufres = getByTagName($registros[0]->tags,'dsdufres');
			$frm_dscidres = getByTagName($registros[0]->tags,'dscidres');
			$frm_nmmaersp = getByTagName($registros[0]->tags,'nmmaersp');
			$frm_nmpairsp = getByTagName($registros[0]->tags,'nmpairsp');
			$frm_cdrlcrsp = getByTagName($registros[0]->tags,'cdrlcrsp');
			
			?>
			<script type="text/javascript">
						
				aux_cdestciv = '<? echo getByTagName($registros[0]->tags,'cdestciv'); ?>';
				
			</script>
			<?
			
						
		}else{?>
			
			<script type="text/javascript">
						
				<? if($operacao != "TI") { ?>
					
					sincronizaArrayResp();
					carregaDadosResp();
										
				<?}?>
				
			</script>
		
		<?}
		
		include('formulario_responsavel_legal.php');
		
	// Se estiver consultando, chamar a tabela que exibe os Representantes/ Procuradores
	}else if( (in_array($operacao,array('CT','AT','IT','FA','FI','FE','SC',''))) && $nmrotina == "Responsavel Legal"){
				include("tabela_responsavel_legal.php");
				
	}else if(in_array($operacao,array('SC','IV','AV','CT','AT','IT','FA','FI','FE'))){
			include("tabela_responsavel_legal.php");
			$operacao = "CT";
	}
	
?>	
	
<script type="text/javascript">	
	
	var operacao_rsp = "<? echo $operacao; ?>"; // operacao_rsp	TB
	var menorida = "<? echo $menorida; ?>";
	var msgConta = "<? echo $msgConta; ?>";
		
	criaTabela = '';
			
	// Quando cpf é digitado na inclusão, e cpf não esta cadastrodo no sistema, então
	// salvo o cpf digitado e atribuo no esse valor novamente ao campo apos a busca
	if ( operacao_rsp == 'TB' && ($('#nrcpfcto','#frmRespLegal').val() == '' || $('#nrcpfcto','#frmRespLegal').val() == 0 )) {
		$('#nrcpfcto','#frmRespLegal').val(cpfaux_rsp);
	}
	
	controlaLayoutResp( operacao_rsp );
	
	if ( msgConta != '' && operacao_rsp == 'SC' ){
		showError('inform',msgConta,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFocoResp(\''+operacao_rsp+'\');'); 
	}
		
	if ( operacao_rsp == 'TE' ){ 
		if( '<? echo $nmrotina; ?>' == 'Responsavel Legal'){
			controlaOperacaoResp('EV'); 
		}else{
			showConfirmacao('Deseja confirmar exclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaArrayResp(\'EV\');controlaOperacaoResp(); criaTabela = \'E\';','bloqueiaFundo(divRotina); controlaOperacaoResp();','sim.gif','nao.gif');		
		}
	}
</script>