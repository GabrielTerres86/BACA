<?php
/**
 * Autor: Jonathan Supero
 * Data: 08/09/2010
 *
 * Funcoes para comunicação com ActiveDiretory

 * Arquivo original: ldap_funcoes.php
 * Antes da migração do OpenLDAP para o ActiveDirectory, utilizava-se o arquivo ldap_funcoes.php
 * Depois da migração, vários funcoes definidas no ldap_funcoes.php forarm trazidas para este arquivo.
 */

/************************************************************
 * Atualização: 30/05/2011
 * Autor      : Rodrigo Oliveira - Supero
 * Objetivo   : Incluída função ldapAD_getEmailUsuario
*************************************************************/
/************************************************************
 * Atualização: 27/03/2013
 * Autor      : Guilherme - Supero
 * Objetivo   : Incluída função intranet_getUserEmpresa
*************************************************************/

//-------------------------------------------------------------------------------------
/**
 * Funcoes originadas do arquivo ldap_funcoes.php, que era utilizado antes da
 *  migração do OpenLDAP para o ActiveDirectory
 */

		//Retitona a data conforme o calculo
		function calcula_data($dia,$mes,$ano){
			return date("Y-m-d", mktime(0, 0, 0, $mes, $dia, $ano));
		}

		function ldap_empresa($COD_EMPRESA){

			global $intranet;

			$SQL = "SELECT
						COD_EMPRESA_LDAP
					FROM
					  	empresa
					WHERE
					  	COD_EMPRESA = ".$COD_EMPRESA;

			$rsEmpresa = $intranet->Execute($SQL) or die($intranet->ErrorMsg());

			return $rsEmpresa->Fields("COD_EMPRESA_LDAP");

		}

		//Retorna o numero de dias conforme a opção escolhida
		function ldap_cacula_data_opcao($opcao){

			//-------------------------------------------------------------------------------------
			//Gera Numero de Dias
			switch ($opcao) {
				case 1://1 Dia
						$tempo = mktime(0,0,0,date("m"),date("d") + 1,date("Y")); break;

				case 2://1 Semana
						$tempo = mktime(0,0,0,date("m"),date("d") + 7,date("Y")); break;

				case 3://1 Mes
						$tempo = mktime(0,0,0,date("m") + 1,date("d"),date("Y")); break;

				case 4://6 Meses
						$tempo = mktime(0,0,0,date("m") + 6,date("d"),date("Y")); break;

				case 5://1 Ano
						$tempo = mktime(0,0,0,date("m"),date("d"),date("Y") + 1); break;

				case 6://Inativo
						$tempo = 0;
				break;
			}
			if (!$tempo) {
				return $tempo;
			}else {
				return date('Y-m-d', $tempo);
			}

		}

		//Diferença entre datas
		function ldap_date_diferenca($date1, $date2)
		{
			//$date1  today, or any other day
			//$date2  date to check against

			$d1 = explode("-", $date1);
			$y1 = $d1[0];
			$m1 = $d1[1];
			$d1 = $d1[2];

			$d2 = explode("-", $date2);
			$y2 = $d2[0];
			$m2 = $d2[1];
			$d2 = $d2[2];

			$date1_set = mktime(0,0,0, $m1, $d1, $y1);
			$date2_set = mktime(0,0,0, $m2, $d2, $y2);

			return(round(($date2_set-$date1_set)/(60*60*24)));
		}

		//Retorna a data apartir dos dias
		function ldad_dia_data($dias){
			return date("Y-m-d", mktime(0,0,0,1,$dias + 1,1970));
		}

		//Converte data para o formato brasil atraves dos dias
		function ldap_getDataBrasil($dias,$separador){
		    $validade = split("-",ldad_dia_data($dias));
		    return $validade[2].$separador.$validade[1].$separador.$validade[0];
		}

		/**
		 * Verifica se o usuário esta bloqueado ou não
		 * Atualizado para o ActiveDirectory
		 */
function ldap_getBloqueado($dsAD,$uid,$printMsn=""){

			$acesso = 0;

			$usuario = ldapAD_getUsuario($dsAD, $uid);

			$mtccshadowexpire     = $usuario[0]['mtccshadowexpire'][0];
			$accountexpires       = $usuario[0]['accountexpires'][0];
			$mtccshadowFlag       = $usuario[0]['mtccshadowflag'][0];
			$mtccshadowlastchange = $usuario[0]['mtccshadowlastchange'][0];
			$useraccountcontrol   = $usuario[0]['useraccountcontrol'][0];

			$acdisable = ($useraccountcontrol |  2);
			$acenable  = ($useraccountcontrol & ~2);

			/*echo "AD: ".$useraccountcontrol."<br>";
			$acdisable = ($useraccountcontrol |  2); // set all bits plus bit 1 (=dec2)
			$acenable  = ($useraccountcontrol & ~2); // set all bits minus bit 1 (=dec2)
			echo "Desabilitado: ".$acdisable."<br>";
			echo "Habilitado: ".$acenable;
			exit;*/

			$dias = ldap_date_diferenca(date("Y-m-d"), ldad_dia_data($mtccshadowlastchange));

			//A conta do usuário expirou
		    // if (ldap_date_diferenca(date("Y-m-d"), ldad_dia_data($mtccshadowexpire)) < 0) {
		    // Verificar se a conta do usuário expirou no AD (accountExpires)
		    if (ldap_date_diferenca(date("Y-m-d"), date('Y-m-d',time_AD2Unix($accountexpires)-1)) < 0) {
			   if ($printMsn == "S")
			   		$MSN = "O usuário expirou.";

			   $acesso = 1;

			}else if ($mtccshadowFlag) { //Usuário não trocou a senha

			   if ($printMsn == "S")
			   		$MSN = "O usuário não trocou sua senha.";

			   $acesso = 2;

		    } else if ($dias < 0 ){  // Senha expirou
			   if ($printMsn == "S")
			   		$MSN = "A senha do usuário expirou.";

			   $acesso = 3;

			} else if ($acdisable==$useraccountcontrol) { // Conta do usuário desabilitada
			   if ($printMsn == "S")
			   		$MSN = "A conta do usuário está desabilitada.";

			   $acesso = 4;
			}
			if ($printMsn == "S") {
				return $MSN;
			}
			else {
				return $acesso;
			}
		}


		function ldap_mensagem_senha_usuario($DES_LOGIN,$DES_SENHA, $NOM_USUARIO_CADASTRADO){

			$STYLE = style();

			$MENSAGEM  = cabecalho("<font color=\"#0000FF\">Usuário Cadastrado</font>",$STYLE);//cabecalho
			$MENSAGEM .= "O usuário ".$NOM_USUARIO_CADASTRADO." foi cadastrado.<br>";
			$MENSAGEM .= "É necessário que o usuário troque sua senha, logo abaixo contêm os dados necessários para realizar a troca.<br><br>";
			$MENSAGEM .= "<b>Login:</b> ".$DES_LOGIN;
			$MENSAGEM .= "<br><b>Senha:</b> ".$DES_SENHA."<br><br>";
			$MENSAGEM .= '<table width="100%" height="25" cellspacing="0" cellpadding="0">
							<tr>
								<td class="txtNormal">Obs.: Essa mensagem é enviada automaticamente favor não responder, obrigado.</td>
							</tr>
						</table>';

			$MENSAGEM .= rodape();//rodape
			return $MENSAGEM;


		}

		function ldap_mensagem_precadastro($NOM_USUARIO_CADASTRADO){

			$STYLE = style();

			$MENSAGEM  = cabecalho("<font color=\"#0000FF\">Usuário Pré-cadastrado</font>",$STYLE);//cabecalho
			$MENSAGEM .= "Foi realizado o pré-cadastro do usuário ".$NOM_USUARIO_CADASTRADO.".<br>";
			$MENSAGEM .= "É necessário que o usuário seja habilitado para que o mesmo possa obter acesso.<br><br>";
			$MENSAGEM .= '<table width="100%" height="25" cellspacing="0" cellpadding="0">
							<tr>
								<td class="txtNormal">Obs.: Essa mensagem é enviada automaticamente favor não responder, obrigado.</td>
							</tr>
						</table>';

			$MENSAGEM .= rodape();//rodape
			return $MENSAGEM;


		}

		// Funcao para retornar os valores de um campo multi-valorado
		function retorna_senhas($dsAD, $uid, $mtccCampo = "mtcclastpassword") {

			$senhas_usuario = ldapAD_getUsuario($dsAD, $uid);

			//Exibe informações
			for ($z=0; $z < $senhas_usuario["count"]; $z++){

				$ii=0;
				for ($i=$z; $ii < $senhas_usuario[$i]["count"]; $ii++){
					$data = $senhas_usuario[$i][$ii];

					if ($senhas_usuario[$i][$ii] == $mtccCampo){
						for ($a=0;$a < 6;$a++) {
							$senhas[] = $senhas_usuario[$i][$data][$a];
						}
					}
				}
			}
			return $senhas;
		}

		function ldap_sambaDateHoje() {
			return mktime(0,0,0,date("m"),date("d"),date("Y"));
		}

		function ldap_sambaDateTrocaSenha($dias) {
			return mktime(0,0,0,date("m"),date("d") + $dias,date("Y"));
		}

		//Retorna as areas de acesso
		function ldap_acesso($MTCCSISTEMA){

			for ($w=0;$w < count($MTCCSISTEMA); $w++){
				if ($MTCCSISTEMA[$w] <> '') {
					$ACESSO += $MTCCSISTEMA[$w];
				}
			}

			return $ACESSO;

		}

		//Atuliza os codios da intranet
		function intranet_setCodigos($campo,$valor){

		   global $intranet;

		   $qyLdapCodigos = "INSERT INTO ldap_codigo (
		   						".$campo."
							 )
							 VALUES (
								 ".$valor."
							 )";

		   $intranet->Execute($qyLdapCodigos) or die($intranet->ErrorMsg());
		}

		//retorna o departamento
		function intranet_getDeptoEmpresa($COD_DEPTO,$CAMPO = ""){

			global $intranet;

			if ($CAMPO <> "") {
				$SQL = "SELECT
							".$CAMPO."
						FROM
							  depto
							, empresa
						WHERE
								depto.COD_DEPTO = ".$COD_DEPTO."
							AND empresa.COD_EMPRESA = depto.COD_EMPRESA";

				$rsDepto = $intranet->Execute($SQL) or die($intranet->ErrorMsg());
				return $rsDepto->Fields($CAMPO);
			}
			else {

				$SQL = "SELECT
							COD_EMPRESA
						FROM
							depto
						WHERE
							COD_DEPTO = ".$COD_DEPTO;

				$rsDepto = $intranet->Execute($SQL) or die($intranet->ErrorMsg());
				return $rsDepto->Fields("COD_EMPRESA");
			}


		}

		//retorna o departamento
		function intranet_getDepartamento($COD_DEPTO){

			global $intranet;

			$SQL = "SELECT * FROM depto WHERE COD_DEPTO = ".$COD_DEPTO;
			$rsDepto = $intranet->Execute($SQL) or die($intranet->ErrorMsg());

			return $rsDepto;

		}

		//retorna o Empresa, login, deptos
		function intranet_getUserEmpresa($COD_USUARIO){

            global $intranet;

            $SQL = "SELECT u.des_login, u.nom_usuario, e.nom_empresa, d.cod_empresa, d.cod_depto, d.nom_depto
                      FROM empresa e, depto d, usuario_depto ud, usuario u
                     WHERE ud.cod_usuario = ". $COD_USUARIO ."
                       AND u.cod_usuario  = ud.cod_usuario
                       AND ud.cod_depto   = d.cod_depto
                       AND d.cod_empresa  = e.cod_empresa";

            $retorno = array( );
            $result  = mysql_query($SQL) or die (mysql_error());
            while( $row = mysql_fetch_assoc( $result ) ) {
                $retorno[] = $row;
                $cont++;
            }

            return $retorno;

        }


		//Gera o login
		function intranet_getLogin($departamento,$SIG_NOMENCLATURA){

			global $intranet;

			//Gera o uidNumber
			$SQL = "SELECT
						  depto.NOM_DEPTO
						, empresa.NOM_EMPRESA
						, empresa.COD_EMPRESA_LDAP AS COOPERATIVA
						, empresa.COD_SEQUENCIA
				   FROM
						  depto
						  , empresa
				   WHERE
						  depto.COD_DEPTO = ".$departamento."
						AND depto.COD_EMPRESA = empresa.COD_EMPRESA";

			$rsCoop = $intranet->Execute($SQL) or die($intranet->ErrorMsg());

			//Seleciona a siga
			$sigla = $SIG_NOMENCLATURA;

			//Codigo da cooperativa no LDAP
			$cooperativa = $rsCoop->Fields("COOPERATIVA");

			//Numero sequencial por cooperativa  para gerar o login
			$sequencia = $rsCoop->Fields("COD_SEQUENCIA");
			if ($sequencia > 0) $sequencia++;
			else $sequencia = 1;

			//Codigo sequencial
			$cod_sequencial = sprintf("%04d",$sequencia);

			//Gera o login
			$uid = $sigla.$cooperativa.$cod_sequencial;

			//Atualiza o numero sequencial
			$intranet->Execute("UPDATE empresa SET COD_SEQUENCIA = ".$sequencia."  WHERE COD_EMPRESA_LDAP = '".$cooperativa."'");

			return $uid;

		}
		//Pega o ultimo uidNumber do banco
		function intranet_getqyUidNumber() {

			global $intranet;

			//Pega o ultimo uidNumber do banco
			$qyUidNumber = "SELECT (MIN(UID_NUMBER) - 1) UID_NUMBER FROM ldap_codigo";
			$rsUidNumber = $intranet->SelectLimit($qyUidNumber) or die($intranet->ErrorMsg());
			$uidNumber   = $rsUidNumber->Fields("UID_NUMBER");

			if ($uidNumber == "" || $uidNumber == 0) {
				$uidNumber = 30000;
			}

			return $uidNumber;

		}
		function intranet_getCodUsuario($DES_LOGIN){

			global $intranet;

			$SQL = "SELECT
						COD_USUARIO
					FROM
						usuario
					WHERE
						DES_LOGIN = '".$DES_LOGIN."'";

			$rsLogin = $intranet->Execute($SQL) or die($intranet->ErrorMsg());
			return $rsLogin->Fields("COD_USUARIO");

		}
		function intranet_getEmpresa($COD_EMPRESA) {

			global $intranet;

			$SQL = "SELECT
						NOM_EMPRESA
					FROM
					 	empresa
					WHERE
					  	COD_EMPRESA_LDAP = '".$COD_EMPRESA."'";

			$rsEmpresa = $intranet->Execute($SQL) or die($intranet->ErrorMsg());
			return $rsEmpresa->Fields("NOM_EMPRESA");

		}

		function ldap_getSID(){
			return "S-1-5-21-646000136-1590812322-232543961";
		}

		function ldap_Password($senha,$comando){
			//$cript = shell_exec("/srv/www/default/html/phpldapadmin/templates/creation/mkntpwd $comando $senha");
			$senha = trim($senha);
			$cript = shell_exec("/usr/local/bin/mkntpwd $comando $senha");
			return trim($cript);
		}

		//Criptografa a senha para o formato CRYPT
		function password_hash($password_clear)
		{
			$final = substr($password_clear,-2);
			$new_value = '{CRYPT}' . crypt( $password_clear, $final);
			return $new_value;
		}

		// Valida se a senha possui os caracteres necessários
		function valida_password($password)
		{
			$password = trim($password);
			// Verifica o tamanho da senha.
			if (strlen($password) < 6 || strlen($password) > 10) {
				return false;
			}

			// Variáveis auxiliares
			$aux_num  = 0; // QTD números
			$aux_char = 0; // QTD Letras
			$aux_esp  = 0; // QTD caracteres especiais

			for ($i = 0; $i < strlen($password); $i++) {
				$aux_letra = substr($password,$i,1);
				if (ctype_alpha($aux_letra)) {
					$aux_char++;
				}
				elseif (ctype_digit($aux_letra)) {
					$aux_num++;
					}
					else {
						$aux_esp++;
				}
			}

			// Retorno.
			if ($aux_esp == 0 && $aux_num >= 2 && $aux_char >= 2) {
				return true;
			}
			else {
				return false;
			}
		}

//-------------------------------------------------------------------------------------






//-------------------------------------------------------------------------------------
/**
 * Funcoes específicas para o ActiveDirectory
 */

function ldapAD_log($func, $msg) {
	$log_file = '/var/www/intranet/logs/logAD_'.date('Ym');
	$log_handle = fopen($log_file, 'a');
	fwrite($log_handle, '['.date('Y-m-d H:i:s')."][ldapAD_funcoes.php][$func]: ");
	fwrite($log_handle , $msg."\r\n");
	fclose($log_handle);
}

/**
 * executa shellscript para alteração de senha no AD
 */
function ldapAD_setSenha($dsAD, $uid, $newPassword) {
	$user = ldapAD_getUsuario($dsAD,$uid);
	$userDn = $user[0]['dn'];
	$senha = $newPassword;

	$newPassword = '"' . $newPassword . '"';
	$len = strlen($newPassword);
	$newPassw = '';
	for ($i = 0; $i < $len; $i++){
		$newPassw .= "{$newPassword{$i}}\000";
	}
	$newPassword = $newPassw;

	$userdata = array();
	$userdata['unicodePwd'] = $newPassword;
	$result = ldap_mod_replace($dsAD, $userDn , $userdata);

	if ($result) {
	    // sincronizar senha no OpenLDAP
	    openLdap_setSenha($uid, $senha);
		return true;
	}
	else {
		ldapAD_log("ldapAD_setSenha($uid)", 'Erro ao trocar senha no AD: ' . ldap_error($dsAD));
	}
}

/**
 * funcoes para manutenção dos Grupos
 * CN=*,OU=Group,DC=cecred,DC=coop,DC=br
 */

// retorna grupos do AD
// parametros: ou passa o nome do grupo (cn), ou passa o filtro (formato ldap)
function ldapAD_getGrupos($dsAD, $grupo='*', $pfilter='') {
	global $dnAD;
	//caminho para os grupos
	$dn = "OU=Group,$dnAD";

	//Parâmetros de Busca - todos os grupos
	$filter = ($pfilter!='') ? $pfilter : "(CN=$grupo)";

	//Efetua a pesquisa.
	$sr = ldap_search($dsAD, $dn, $filter);

	//Retorna 'registros'
	return ldap_get_entries($dsAD, $sr);
}

// excluir um grupo do AD
function ldapAD_deleteGrupo($dsAD, $grupo) {
	global $dnAD;
	$dn = "CN=$grupo,OU=Group,$dnAD";
    if ( !ldap_delete($dsAD, $dn) ) {
        $msg = ldap_error($dsAD);
        ldapAD_log("ldapAD_deleteGrupo($grupo)", "Erro ao excluir grupo: $msg");
    }
}

// modifica um grupo do AD
function ldapAD_modifyGrupo($dsAD, $grupo, $info) {
	global $dnAD;
	$dn = "CN=$grupo,OU=Group,$dnAD";
	if (!ldap_modify($dsAD,$dn,$info)) {
        $msg = ldap_error($dsAD);
        ldapAD_log("ldapAD_modifyGrupo($grupo)", "Erro ao modificar grupo: $msg");
	}
}

// adiciona um grupo no AD
function ldapAD_addGrupo($dsAD, $grupo, $info) {
	global $dnAD;
	$dn = "CN=$grupo,OU=Group,$dnAD";
	$info['msSFU30NisDomain']	= 'cecred';
	$info['objectClass'] 		= 'group';
	$info['sAMAccountName']		= $grupo;
	if (!ldap_add($dsAD,$dn,$info)){
        $msg = ldap_error($dsAD);
        ldapAD_log("ldapAD_addGrupo($grupo)", "Erro ao criar grupo: $msg");
	}

	// outro atributos do registro
	//$info['groupType'] 			= '-2147483646';
	//$info['instanceType'] 		= '4';
	//$info['cn']
	//$info['description']
	//$info["gidNumber"]
    //$info['member']
	//$info['MTCCCodCooperativa']
	//$info["MTCCDiaAcesso"]
	//$info['MTCCHomeDir']
	//$info['MTCCHoraAcesso']

	// atributos retirados do ActiveDiretory
	//$info["sambaGroupType"] 	= '2';
	//$info["sambaSID"] 		= 'S-1-5-21-646000136-1590812322-232543961-5906';
}




/**
 * funcoes para manutenção dos Usuários
 * CN=*,OU=Usuarios,OU=003 - Cecred,OU=Cooperativas,DC=cecred,DC=coop,DC=br
 */

// retorna usuário do AD
function ldapAD_getUsuario($dsAD, $login='') {
	//caminho para os usuarios (exemplo): CN=f0030134,OU=Usuarios,OU=003 - Cecred,OU=Cooperativas,DC=cecred,DC=coop,DC=br
	global $dnAD;
	$dn = "OU=Cooperativas,$dnAD";
	$filter = "(CN=$login)";

	//Efetua a pesquisa.
	$sr = ldap_search($dsAD, $dn, $filter);
	$result = ldap_get_entries($dsAD, $sr);

	// se não encontrou em OU=Cooperativas, busca em OU=Liberados
	#if (!$result['count']) {
    #	$dn = "OU=TesteWebsense,$dnAD";
	#	$sr = ldap_search($dsAD, $dn, $filter);
	#	$result = ldap_get_entries($dsAD, $sr);
	#}

	//Retorna registro
	return $result;
}

// retorna o email do usuario no AD
// parametro: login do usuario
function ldapAD_getEmailUsuario($dsAD, $login){
	$usuario = ldapAD_getUsuario($dsAD, $login);
	return ($usuario[0]['mail'][0]);
}

// excluir um usuario do AD
// parametros: login do usuário ou DN completo
function ldapAD_deleteUsuario($dsAD, $login='', $dn='') {
	if ($login!='') {
		$usuario = ldapAD_getUsuario($dsAD, $login);
		$dn = $usuario[0]['dn'];
	}

	if ($dn!='') {

		if (!ldap_delete($dsAD, $dn)) {
	        $msg = ldap_error($dsAD);
	        ldapAD_log("ldapAD_deleteUsuario($login)", "Erro ao excluir usuário: $msg");
		}

		else {
			// excluir referencias do usuário, nos grupos
			// busca todos os grupos que referenciam o usuário que está sendo excluído
			$grupos = ldapAD_getGrupos($dsAD, '', "member=$dn");
			//exclui referencias do usuário excluído nos grupos
			if ($grupos['count']>0){
			    $count = $grupos['count'];
			    for ($i=0; $i<$count; $i++) {
			        $dn_grupo = $grupos[$i]['dn'];
			        if ($dn_grupo!='') {
			            $info_grupo = array('member'=>$dn);
			            ldap_mod_del($dsAD, $dn_grupo, $info_grupo);
			        }
			    }
			}

			// delete usuario do OpenLDAP
			openLdap_deleteUsuario($login);
		}
	}
}

// retorna GrupoGPO do usuário (Usuarios,Administradores,Suporte,Moveis,Liberados)
function ldapAD_getGrupoGPOUsuario($dn) {
	//exemplo: CN=f0030218,OU=Usuarios,OU=003 - Cecred,OU=Cooperativas,DC=cecred,DC=coop,DC=br
    $estrutura = explode(',', $dn);
    $grupoGPO = explode('=',$estrutura[1]);
    $grupoGPO = $grupoGPO[1];
    return $grupoGPO;
}

// retorna o DN de uma cooperativa
function ldapAD_getCooperativa($dsAD, $COD_COOPERATIVA) {
	global $dnAD;
	$dn = "OU=Cooperativas,$dnAD";
	$filter = "(OU=$COD_COOPERATIVA - *)";
	$sr = ldap_search($dsAD, $dn, $filter);
	return ldap_get_entries($dsAD, $sr);
}

// mover o usuário para outro Grupo de GPO (OU = Usuarios/Suporte/Liberados)
// - Usuarios - todas as cooperatives possuem esta OU
// - Suporte - somente CECRED possuem esta OU
// - Liberados - esta OU está localizada na raiz do AD
function ldapAD_moveUsuario($dsAD, $login, $newGrupoGPO) {
	global $COD_CECRED_LDAP;
	global $dnAD;
    // Busca DN do usuário
    $usuario = ldapAD_getUsuario($dsAD, $login);
    $dn = $usuario[0]['dn'];

	$grupoGPO = ldapAD_getGrupoGPOUsuario($dn);
	if ($newGrupoGPO != $grupoGPO) {

	    $destino = '';

		switch ($newGrupoGPO) {
		    case 'Usuarios':
	        $coop = ldapAD_getCooperativa($dsAD, substr($login,1,3));
	        $destino = @$coop[0]['dn'];
	        if ($destino!='') $destino = 'OU=Usuarios,'.$destino;
		    break;

		    case 'Suporte':
		    // verifica se usuário é da CECRED
		    if (substr($login,1,3) == str_pad($COD_CECRED_LDAP, 3, '0', STR_PAD_LEFT)) {
		        $destino = "OU=Suporte,OU=003 - Cecred,OU=Cooperativas,$dnAD";
		    }
		    break;

		    case 'Liberados':
		    $destino = "OU=Liberados,$dnAD";
		    break;
		}

		if ($destino!='') {
		    if (!ldap_rename ($dsAD, $dn, "CN=$login",$destino, true) ) {
		        $msg = ldap_error($dsAD);
		        ldapAD_log("ldapAD_modifyUsuario($login)", "Erro ao modificar usuário: $msg");
		    }
		}

	}
}

// modificar um Usuário no AD
function ldapAD_modifyUsuario($dsAD, $login, $info, $newGrupoGPO='') {
    // Busca DN do usuário
    $usuario = ldapAD_getUsuario($dsAD, $login);
    $dn = $usuario[0]['dn'];

	if (!ldap_modify($dsAD,$dn,$info)) {
        $msg = ldap_error($dsAD);
        ldapAD_log("ldapAD_modifyUsuario($login)", "Erro ao modificar usuário: $msg");
	}
}

// adiciona um Usuário no AD
function ldapAD_addUsuario($dsAD, $dn, $info, $senha='') {

	if (ldap_add($dsAD,$dn,$info)) {
		openLdap_addUsuario($info, $senha);
	}
	else {
        $msg = ldap_error($dsAD);
        ldapAD_log("ldapAD_addUser($login)", "Erro ao adicionar usuário: $msg");
	}

	// outros atributos do registro (vindos no parametro $info)
	//$info['cn'] = 'f0010001';
	//$info['description'] = 'Nome Usuário';
	//$info['facsimileTelephoneNumber'] = '';
	//$info['gecos'] = 'Nome - Fone';
	//$info['gidnumber'] = '';
	//$info['loginShell'] = '/usr/bin/sh';
	//$info['mail'] = '';
	//$info['mtccacessoexporadico'] = '0';
	//$info['mtccacessovpn'] = '0';
	//$info['MTCCBairro'] = '';
	//$info['MTCCCelNumber'] = '';
	//$info['MTCCCodDepto'] = '';
	//$info['MTCCComplemento'] = '';
	//$info['MTCCDiaAcesso'] = '';
	//$info['Mtcchoraacesso'] = '';
	//$info['mtcclastpassword'] = '';
	//$info['mtccserver'][] = '';
	//$info['mtccserver'][] = '';
	//$info['mtccshadowexpire'] = '';
	//$info['mtccshadowinactive'] = '';
	//$info['mtccshadowlastchange'] = '';
	//$info['mtccsistema'] = '';
	//$info['objectClass'] = 'user';
	//$info['postalCode'] = '';
	//$info['telephonenumber'] = '';
	//$info['uid'] = $info['cn'];
	//$info['uidnumber'] = '';
	//$info['displayName'] = $info['description'];
	//$info['givenName'] = $info['description'];
	//$info['sn'] = $info['description'];
	//$info['mobile'] = $info['MTCCCelNumber'];
	//$info['streetAddress'] = 'teste';
	//$info['unixHomeDirectory'] = '/usr/coop/cecred';
	//$info['userPrincipalName'] = $info['cn'].'@cecred.coop.br';
	//$info['msSFU30NisDomain']	= 'cecred';
	//$info['sAMAccountName']		= $info['cn'];
	//$dn = 'CN=e0030001,OU=Usuarios,OU=003 - cecred,OU=Cooperativas,DC=cecred,DC=coop,DC=br';
}


/**
 * valida autenticaçao do usuário no AD
 */
function ldapAD_login($dsAD, $login, $senha) {
	
	// busca usuario pelo login
	$usuario = ldapAD_getUsuario($dsAD, $login);
	if ($usuario == '' || $usuario[0]['dn'] == '') {		
		return false;
	}

	// senha em branco
	if (trim($senha) == '') {		
	    return false;
	}

	// autenticação no ActiveDirectory
	
	// endereço dos servidores ActiveDirectory
	global $srv_ldapAD;
	reset($srv_ldapAD);

	$ldapUser = false;
	while ( $ldapUser==false && list($i,$ip)=each($srv_ldapAD) ) {
		$port = ereg('ldaps:', $ip) ? '636':'389'; //ldap:389 ou ldaps:636
		$dsUser = ldap_connect($ip, $port);
		//configuracoes
		ldap_set_option( $dsUser, 17, 3 ); // LDAP_OPT_PROTOCOL_VERSION = 3
		ldap_set_option( $dsUser, 8, 0);   // LDAP_OPT_REFERRALS = 0
		//autentica		
		$ldapUser = @ldap_bind($dsUser, $usuario[0]['dn'], $senha);
	}	

	if ($ldapUser) {
	    @ldap_unbind($dsUser);
	    return true;
	}
	else {				
	    return false;
	}
}


/**
 * retorna grupos da VPN
 */
function ldapAD_getGruposVPN($dsAD) {
	global $dnAD;
	$dn = "OU=VPN,$dnAD";
	$filter = 'CN=*';

	//Efetua a pesquisa.
	$sr = ldap_search($dsAD, $dn, $filter);

	//Retorna 'registros'
	return ldap_get_entries($dsAD, $sr);
}

/**
 * remove grupos de VPN de um usuário
 */
function ldapAD_removeGruposVPN($dsAD, $uid) {
	global $dnAD;
	$user = ldapAD_getUsuario($dsAD,$uid);
	$memberof = $user[0]['memberof'];
	for ($i=0; $i<$memberof['count']; $i++) {
	    $grupo = $memberof[$i];
		if (ereg(',OU=VPN,'.$dnAD.'$', $grupo)) {
		    $info = array();
			$info['member'] = $user[0]['dn'];
			if (!ldap_mod_del($dsAD, $grupo, $info)) {
				$msg = ldap_error($dsAD);
				ldapAD_log("ldapAD_removeGruposVPN($uid)", "Erro ao remover grupos VPN do usuário: $msg");
			}
		}
	}
}

/**
 * adiciona grupo VPN a um usuário
 */
function ldapAD_addGrupoVPN($dsAD, $grupo, $uid) {
	$user = ldapAD_getUsuario($dsAD,$uid);
	$info['member'] = $user[0]['dn'];
	if (!ldap_mod_add($dsAD, $grupo, $info)) {
        $msg = ldap_error($dsAD);
        ldapAD_log("ldapAD_addGrupoVPN($grupo,$uid)", "Erro ao adicionar grupo VPN ao usuário: $msg");
        return false;
	}
	return true;
}

/**
 * retorna grupo VPN de um usuário
 */
function ldapAD_getGrupoVPN($dsAD, $uid) {
    global $dnAD;
	$user = ldapAD_getUsuario($dsAD,$uid);
	$dn = "OU=VPN,$dnAD";
	$filter = 'member='.$user[0]['dn'];
	//Efetua a pesquisa.
	$sr = ldap_search($dsAD, $dn, $filter);
	//Retorna 'registros'
	return ldap_get_entries($dsAD, $sr);
}


/**
 * Acesso proxy
 * retorna grupos de Proxy
 */
function ldapAD_getGruposProxy($dsAD) {
	global $dnAD;
	$dn = "OU=Proxy,$dnAD";
	$filter = 'objectClass=group';

	//Efetua a pesquisa.
	$sr = ldap_search($dsAD, $dn, $filter);

	//Retorna 'registros'
	return ldap_get_entries($dsAD, $sr);
}
/**
 * remove grupos de Proxy de um usuário
 */
function ldapAD_removeGruposProxy($dsAD, $uid) {
	global $dnAD;
	$user = ldapAD_getUsuario($dsAD,$uid);
	$memberof = $user[0]['memberof'];
	for ($i=0; $i<$memberof['count']; $i++) {
	    $grupo = $memberof[$i];
		if (ereg(',OU=Proxy,'.$dnAD.'$', $grupo)) {
		    $info = array();
			$info['member'] = $user[0]['dn'];
			if (!ldap_mod_del($dsAD, $grupo, $info)) {
				$msg = ldap_error($dsAD);
				ldapAD_log("ldapAD_removeGruposProxy($uid)", "Erro ao remover grupos Proxy do usuário: $msg");
			}
		}
	}
}
/**
 * adiciona grupo Proxy a um usuário
 */
function ldapAD_addGrupoProxy($dsAD, $grupo, $uid) {
	$user = ldapAD_getUsuario($dsAD,$uid);
	$info['member'] = $user[0]['dn'];
	if (!ldap_mod_add($dsAD, $grupo, $info)) {
        $msg = ldap_error($dsAD);
        ldapAD_log("ldapAD_addGrupoProxy($grupo,$uid)", "Erro ao adicionar grupo Proxy ao usuário: $msg");
        return false;
	}
	return true;
}
/**
 * retorna grupo Proxy de um usuário
 */
function ldapAD_getGrupoProxy($dsAD, $uid) {
    global $dnAD;
	$user = ldapAD_getUsuario($dsAD,$uid);
	$dn = "OU=Proxy,$dnAD";
	$filter = 'member='.$user[0]['dn'];
	//Efetua a pesquisa.
	$sr = ldap_search($dsAD, $dn, $filter);
	//Retorna 'registros'
	return ldap_get_entries($dsAD, $sr);
}


//-------------------------------------------------------------------------------------
/**
 * Funções de conversão de DATA do ActiveDirectory
 *
 * Formatos:
 *   DateBR: dd/mm/yyyy
 *   TimeUnix: número de segundos desde 01/01/1970
 *   TimeAD: número de nanosegundos desde 01/01/1601
 *
 */

// converte uma data do Unix para o formato Interval do ActiveDirectory
function time_Unix2AD($timeUnix) {
	return ($timeUnix + 11644473600) * 10000000;
}
function time_AD2Unix($timeAD) {
	return $timeAD / 10000000 - 11644473600;
}


//-------------------------------------------------------------------------------------
/**
 * Funcoes de sincronização do AD para o OpenLDAP
 */
/**
 * rotina para sincronizar senha do AD no OpenLDAP
 * sincroniza senha do OpenLDAP e Samba
 */
function openLdap_setSenha($uid, $newPassword) {
	// abre conexao com OpenLDAP
	include_once dirname(__FILE__).'/../Connections/ldap.php';

	// informacoes a alterar no OpenLDAP
	$info['userpassword'] = password_hash($newPassword);
	$info['shadowflag']   = 0;// 1 - Bloqueado, 0 - Liberado
	$info['mtccshadowlastchange']	= @ldap_date_diferenca('1970-1-1',calcula_data(date('d') + 30,date('m'),date('Y')));

	//Samba - Troca as novas senhas, atualiza o tempo de acesso da senha
	$info['sambaLMPassword']	= ldap_Password($newPassword,'-L');//Senha, Comando
	$info['sambaNTPassword']	= ldap_Password($newPassword,'-N');//Senha, Comando
	$info['sambapwdcanchange']	= ldap_sambaDateHoje();//sambaPwdCanChange - proxima data em que a senha pode ser alterada, no nosso caso, este valor sera igual ao do campo sambaPwdLastSet.
	$info['sambapwdlastset']	= ldap_sambaDateHoje();//sambaPwdLastSet - data em que a senha foi alterada
	$info['sambapwdmustchange']	= 9999999999;//sambaPwdMustChange - data da proxima alteracao da senha no samba

	$dn = "uid=$uid,ou=People,o=Cecred";
	if (!ldap_modify($ds,$dn,$info)) {
        ldapAD_log("openLdap_setSenha($uid)", 'Erro ao trocar senha no AD: ' . ldap_error($ds));
	}

 	// fecha conexao com OpenLDAP
	ldap_close($ds);
}

function openLdap_addUsuario($info, $senha) {
	// abre conexao com OpenLDAP
	include_once dirname(__FILE__).'/../Connections/ldap.php';

	// informacoes a alterar no OpenLDAP
	$info['userpassword'] = password_hash($senha);
	$info['shadowflag']   = 1;// 1 - Bloqueado, 0 - Liberado
	$info['mtccshadowlastchange']	= @ldap_date_diferenca('1970-1-1',calcula_data(date('d') + 30,date('m'),date('Y')));

	$info['sambaLMPassword']   		= ldap_Password($senha,'-L');//Senha, Comando
	$info['sambaNTPassword']  		= ldap_Password($senha,'-N');//Senha, Comando
	$info['sambaacctflags']   		= '[U           ]';//11 espaços
	$info['sambaprimarygroupsid']   = ldap_getSID().'-513';
	$info['sambasid'] 		  		= ldap_getSID().'-'.$info['uidNumber'];
	$info['sambapwdcanchange']   	= ldap_sambaDateHoje();//sambaPwdCanChange - proxima data em que a senha pode ser alterada, no nosso caso, este valor sera igual ao do campo sambaPwdLastSet.
	$info['sambapwdlastset']   		= ldap_sambaDateHoje();//sambaPwdLastSet - data em que a senha foi alterada
	$info['sambapwdmustchange']  	= ldap_sambaDateTrocaSenha(30);//sambaPwdMustChange - data da proxima alteracao da senha no samba

	$info['homeDirectory'] = $info['unixHomeDirectory'];
	$info['fax'] = $info['facsimileTelephoneNumber'];
	$info['postalAddress'] = $info['streetAddress'];
	$info['mtcccodcooperativa'] = '3';
	$info['sambahomedrive'] = 'F:';
	$info['sambalogonscript'] = 'logon.exe';
	$info['MTCCCodNivel'] = '1';
	$info['shadowexpire'] = '99999';
	$info['shadowinactive'] = '-1';
	$info['shadowlastchange'] = '-1';
	$info['shadowmax'] = '999999';
	$info['objectClass']= array('top','account','MTCCAccount','posixAccount','shadowAccount','sambaSamAccount');

	unset($info['department']);
	unset($info['company']);
	unset($info['mobile']);
	unset($info['facsimileTelephoneNumber']);
	unset($info['streetAddress']);
	unset($info['unixHomeDirectory']);
	unset($info['userPrincipalName']);
	unset($info['displayName']);
	unset($info['mtccshadowflag']);
	unset($info['accountexpires']);
	unset($info['msSFU30NisDomain']);
	unset($info['sAMAccountName']);
	unset($info['userAccountControl']);
	unset($info['givenName']);

	$dn = "uid={$info['uid']},ou=People,o=Cecred";
	if (!ldap_add($ds,$dn,$info)) {
        ldapAD_log("openLdap_addUsuario({$info['uid']})", 'Erro ao adicionar usuário no AD: ' . ldap_error($ds));
	}

 	// fecha conexao com OpenLDAP
	ldap_close($ds);
}

function openLdap_deleteUsuario($login) {
	// abre conexao com OpenLDAP
	include_once dirname(__FILE__).'/../Connections/ldap.php';

	$dn = "uid=$login,ou=People,o=Cecred";
	if (!ldap_delete($ds, $dn)) {
        ldapAD_log("openLdap_deleteUsuario($login)", 'Erro ao excluir usuário no AD: ' . ldap_error($ds));
	}

 	// fecha conexao com OpenLDAP
	ldap_close($ds);
}

