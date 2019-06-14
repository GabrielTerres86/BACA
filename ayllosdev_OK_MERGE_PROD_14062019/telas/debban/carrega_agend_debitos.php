<?php 

/*!
 * FONTE        : carrega_agend_debitos.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/12/2017
 * OBJETIVO     : Carrega agendamento de debitos de convenios do Bancoob
 * -------------- 
 * ALTERAÇÕES   : 
 *
 * --------------
*/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	if (!isset($_POST["cddopcao"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
			
	$cddopcao = $_POST["cddopcao"] == "" ? 0 : $_POST["cddopcao"];
    $cdcoptel = $_POST["cdcoptel"] == "" ? 0 : $_POST["cdcoptel"];
    $dtmvtopg = $_POST["dtmvtopg"] == "" ? 0 : $_POST["dtmvtopg"];
	
	// Monta o xml de requisição
	$xml = new XmlMensageria();    
    $xml->add('cddopcao',$cddopcao);
    $xml->add('cdcoptel',$cdcoptel);
    $xml->add('dtmvtopg',$dtmvtopg);
   
   
    $xmlResult = mensageria($xml, "TELA_DEBBAN", "CARREGA_AGENDEB_BANCOOB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErro($msgErro);
        exit();
    }
    
    
    $registros = $xmlObj->roottag->tags[0]->tags;
	
	function exibeErro($msgErro) {
		echo 'showError("error","'.$msgErro.'","Alerta - Contas","estadoInicial();");';
		echo 'hideMsgAguardo();';		
		exit();	
	}
		
?>


<form id="frmConsultaDados" class="formulario" name="frmConsultaDados">
	<fieldset>
		<legend> Agendamentos </legend>
		<div class="divRegistros">
			<table>
				<thead>
				<tr><th>Conta/dv</th>
					<th>Tipo</th>
					<th>Descrição da transação</th>
					<th>Valor</th>
				</tr>			
				</thead>
				<tbody> 
					<?php
                        $idreg = 0; 
						foreach($registros as $registro){
                            // Setar valores daprimeira linha
                            if ( $idreg == 0){
                                echo "<script>  cDscooper.val('".getByTagName($registro->tags,'dscooper')."')
                                                cNrdocmto.val('".getByTagName($registro->tags,'nrdocmto')."')
                                                cDttransa.val('".getByTagName($registro->tags,'dttransa')."')
                                                cHrtransa.val('".getByTagName($registro->tags,'hrtransa')."')
                                                cDslindig.val('".getByTagName($registro->tags,'dslindig')."'); </script>";  
                            }
                           
                            
					?>
					<tr id="<? echo $idreg; ?>" >
						<td>
                            <input type='hidden' name='cdcooper' id='cdcooper' value='<? echo getByTagName($registro->tags,'cdcooper'); ?>'>                        
                            <input type='hidden' name='dscooper' id='dscooper' value='<? echo getByTagName($registro->tags,'dscooper'); ?>'>
                            <input type='hidden' name='nrdocmto' id='nrdocmto' value='<? echo getByTagName($registro->tags,'nrdocmto'); ?>'>
                            <input type='hidden' name='dttransa' id='dttransa' value='<? echo getByTagName($registro->tags,'dttransa'); ?>'>
                            <input type='hidden' name='hrtransa' id='hrtransa' value='<? echo getByTagName($registro->tags,'hrtransa'); ?>'>
                            <input type='hidden' name='dslindig' id='dslindig' value='<? echo getByTagName($registro->tags,'dslindig'); ?>'>
                            
                            <?php echo getByTagName($registro->tags,'nrdconta'); ?> 
                        </td>
						<td><?php echo getByTagName($registro->tags,'dstiptra'); ?> </td>
						<td><?php echo getByTagName($registro->tags,'dstransa'); ?> </td>
						<td><?php echo getByTagName($registro->tags,'vllanaut'); ?> </td>
					</tr>
					<? $idreg++; } ?>
				</tbody>		
			</table>
		</div>
	</fieldset>
</form>
