<?php
/*!
 * FONTE        : logdda_consulta.php
 * CRIAÇÃO      : David (CECRED)
 * DATA CRIAÇÃO : Março/2011
 * OBJETIVO     : Capturar dados para tela LOGDDA
 * --------------
 * ALTERAÇÕES   :
 * 001: [02/03/2011] David (CECRED): Desenvolver a tela LOGDDA
 * 002: [30/11/2012] Daniel(CECRED): Alterado layout da tela (Daniel).
 * -------------- 
 */ 
?>

<?php	

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");		
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	if (!isset($_POST["dtmvtlog"])) {		
		exibirErro('error','Parâmetros incorretos','Alerta - Ayllos','',false);
	}	
	
	$dtmvtlog = $_POST['dtmvtlog'];	
	
	// Se data informada não for uma data válida
	if (!validaData($dtmvtlog)) {
		exibirErro('error','Data de transação inválida.','Alerta - Ayllos','',false);
	}	
	
	// Monta o xml de requisição
	$xmlLogdda  = '';
	$xmlLogdda .= '<Root>';
	$xmlLogdda .= '	 <Cabecalho>';
	$xmlLogdda .= '    <Bo>b1wgen0078.p</Bo>';
	$xmlLogdda .= '    <Proc>lista-erros-dda</Proc>';
	$xmlLogdda .= '  </Cabecalho>';
	$xmlLogdda .= '  <Dados>';
	$xmlLogdda .= '    <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlLogdda .= '    <cdagecxa>'.$glbvars['cdagenci'].'</cdagecxa>';
	$xmlLogdda .= '    <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlLogdda .= '    <cdopecxa>'.$glbvars['cdoperad'].'</cdopecxa>';
	$xmlLogdda .= '    <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlLogdda .= '    <idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlLogdda .= '    <dtmvtlog>'.$dtmvtlog.'</dtmvtlog>';		
	$xmlLogdda .= '    <nritmini>0</nritmini>';
	$xmlLogdda .= '    <nritmfin>0</nritmfin>';	
	$xmlLogdda .= '  </Dados>';
	$xmlLogdda .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xmlLogdda);
	$xmlObjeto = getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {			
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','$(\'#dtmvtlog\',\'#frmCabLogdda\').focus()',false);
	} 
	
	$qterrdda  = $xmlObjeto->roottag->tags[0]->attributes["QTERRDDA"];	
	$registros = $xmlObjeto->roottag->tags[0]->tags;	
	
	if ($qterrdda == 0) {
		?>
		showError('inform','Nenhum registro de erro foi encontrado.','Alerta - Ayllos','$(\'#dtmvtlog\',\'#frmCabLogdda\').focus()');
		$("#divLogdda > #tabConteudo").html('');
		controlaLayout('');
		<?php
	} else { 		
		?>
		strHTML = '';		 
		strHTML += '<legend>Registros</legend>';
		strHTML += '<div class="divRegistros">';
		strHTML += '  <table>';
		strHTML += '    <thead>';
		strHTML += '      <tr>';
		strHTML += '        <th>Hora</th>';
		strHTML += '        <th>Conta/dv</th>';
		strHTML += '        <th>Nome</th>';
		strHTML += '        <th>Erro</th>';
		strHTML += '      </tr>';
		strHTML += '    </thead>';
		strHTML += '    <tbody>';
		
		detalhe = new Array();
		detalhe[0] = ''; /* Registro 0 não será utilizado no array */
		
		<? foreach( $registros as $ddaerror ) { ?>	
		strHTML += '      <tr>';
		strHTML += '        <td><span><? echo getByTagName($ddaerror->tags,'hrtraint') ?></span><? echo getByTagName($ddaerror->tags,'hrtransa') ?><input type="hidden" id="idseqlog" name="idseqlog" value="<? echo getByTagName($ddaerror->tags,'idseqlog') ?>" /></td>';
		strHTML += '        <td><span><? echo getByTagName($ddaerror->tags,'nrdconta') ?></span><? echo formataNumericos('zzzz,zzz-z',getByTagName($ddaerror->tags,'nrdconta'),'.-') ?></td>';
		strHTML += '        <td><span><? echo getByTagName($ddaerror->tags,'nmprimtl') ?></span><? echo stringTabela(getByTagName($ddaerror->tags,'nmprimtl'),35,'maiuscula') ?></td>';
		strHTML += '        <td><span><? echo getByTagName($ddaerror->tags,'dsreserr') ?></span><? echo getByTagName($ddaerror->tags,'dsreserr') ?></td>';	
		strHTML += '      </tr>';	
		
		ObjDetalhe = new Object(); 		
		ObjDetalhe.dttransa = '<? echo getByTagName($ddaerror->tags,'dttransa') ?>'; 
		ObjDetalhe.hrtransa = '<? echo getByTagName($ddaerror->tags,'hrtransa') ?>'; 		 
		ObjDetalhe.nrdconta = '<? echo formataNumericos('zzzz,zzz-z',getByTagName($ddaerror->tags,'nrdconta'),'.-') ?>'; 
		ObjDetalhe.nmprimtl = '<? echo getByTagName($ddaerror->tags,'nmprimtl') ?>'; 
		ObjDetalhe.dscpfcgc = '<? echo getByTagName($ddaerror->tags,'dscpfcgc') ?>'; 
		ObjDetalhe.nmmetodo = '<? echo getByTagName($ddaerror->tags,'nmmetodo') ?>'; 
		ObjDetalhe.cdderror = '<? echo getByTagName($ddaerror->tags,'cdderror') ?>';
		ObjDetalhe.dsderror = '<? echo addslashes(getByTagName($ddaerror->tags,'dsderror')) ?>'; 

		detalhe[<? echo getByTagName($ddaerror->tags,'idseqlog') ?>] = ObjDetalhe; 
		<? } ?>	
		
		strHTML += '    </tbody>';
		strHTML += '  </table>';
		strHTML += '</div>';
		strHTML += '<div id="divBotoes">';
		strHTML += '  <a href="#" class="botao" id="btVoltar" onClick="Voltar();">Voltar</a>';
		strHTML += '  <a href="#" class="botao" id="btConsultar" onClick="mostraDetalhamento();">Consultar</a>';
		strHTML += '</div>';		
		$("#divLogdda > #tabConteudo").html(strHTML);		
		controlaLayout('C',true);
		<?php 
	}
	
?>		