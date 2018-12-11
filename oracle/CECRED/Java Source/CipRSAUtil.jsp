create or replace and compile java source named CECRED."CipRSAUtil" as
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.KeyFactory;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.interfaces.RSAPrivateKey;
import java.security.spec.EncodedKeySpec;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;
import java.util.Arrays;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;

public class CipRSAUtil {

	private static final String ALGORITHM_CHAVE  = "RSA";
	private static final String ALGORITHM_HASH   = "SHA256withRSA";
	private static final String ALGORITHM_CIPHER = "DESede/CBC/NoPadding";
	private static final String PROVIDER_CIPHER  = "RSA/ECB/PKCS1Padding";


	public static String encrypt3Des(String valueToEncrypt, String sortedKey) throws Exception {

		// Leitura a chave
		byte[] tdesKeyData = DatatypeConverter.parseHexBinary(sortedKey);

		// Converter chave
		SecretKeySpec key = new SecretKeySpec(tdesKeyData, "DESede");

		// Gerar o IV
		final IvParameterSpec iv = new IvParameterSpec(Arrays.copyOf(key.getEncoded(), 8));

		// Cifrar o conteudo
		Cipher cipher = Cipher.getInstance(ALGORITHM_CIPHER);
		cipher.init(Cipher.ENCRYPT_MODE, key, iv);

		// Leitura do texto a criptografar
		byte[] bytesToEncrypt = DatatypeConverter.parseHexBinary(valueToEncrypt);

		byte[] encryptedBytes = cipher.doFinal( bytesToEncrypt );

		return DatatypeConverter.printHexBinary(encryptedBytes);
	}

	/**
	 * Realizar a encriptação da chave 3Des utilizada para criptografar a mensagem
	 * 
	 * @author Renato Darosci - Supero
	 * @return String Hexadecimal
	 */
	public static String encrypt3DesKey(String keyToEncrypt, String publicKey) throws IllegalBlockSizeException, BadPaddingException, NoSuchAlgorithmException, InvalidKeySpecException, NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, NoSuchProviderException {

		byte[] cipherText;
		byte[] pubKeyArray  = CipBase64.decode(publicKey);

		// Leitura da chave a ser criptografada
		byte[] desKeyData = DatatypeConverter.parseHexBinary(keyToEncrypt);

		// Converter chave
		Key key = new SecretKeySpec(desKeyData, ALGORITHM_CIPHER); 

		// Definir o RSA cipher object
		Cipher cipher = Cipher.getInstance(PROVIDER_CIPHER);  

		// Instanciar a chave com base no texto recebido
		KeyFactory keyFactory = KeyFactory.getInstance(ALGORITHM_CHAVE);
		EncodedKeySpec publicKeySpec = new X509EncodedKeySpec(  pubKeyArray  );
		PublicKey publicKeyObj = keyFactory.generatePublic(publicKeySpec);

		// Inicializar o Cipher
		cipher.init(Cipher.WRAP_MODE, publicKeyObj);

		// Realizar o embrulho da chave
		cipherText = cipher.wrap(key);

		// Retornar dados criptografados
		return DatatypeConverter.printHexBinary(cipherText);
	}

	/**
	 * Realizar a decriptação da mensagem utilizando 3Des 
	 * 
	 * @author Renato Darosci - Supero
	 * @return String Hexadecimal 
	 */  
	public static String decrypt3Des(String valueToDecrypt, String tDesKey) throws Exception {

		// Leitura da mensagem criptografada
		byte[] bytesToDecrypt = DatatypeConverter.parseHexBinary(valueToDecrypt);

		// Ler a chave utilizada  
		byte[] MY_KEY = DatatypeConverter.parseHexBinary(tDesKey); // 24-bytes
		final SecretKeySpec secretKeySpec = new SecretKeySpec(MY_KEY, "DESede");

		// Definir o vetor de Inicialização
		byte[] MY_IV = Arrays.copyOf(MY_KEY, 8); // 8-bytes
		final IvParameterSpec iv = new IvParameterSpec(MY_IV);

		// Define a instancia do algoritmo de cifra
		final Cipher cipher = Cipher.getInstance(ALGORITHM_CIPHER);

		// Inicializa o decriptador com a chave e o iv
		cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, iv);

		// REALIZAR A DESCRIPTOGRAFIA DA MENSAGEM
		final byte[] decrypted = cipher.doFinal( bytesToDecrypt );

		// Converter o retorno
		String retVal = DatatypeConverter.printHexBinary(decrypted);

		return retVal;
	}


	/**
	 * Realizar a decriptação da chave 3Des utilizada para criptografar a mensagem
	 * 
	 * @author Renato Darosci - Supero
	 * @return String Hexadecimal
	 */  
	public static String decrypt3DesKey(String valueToDecrypt, String privateKey) throws Exception {
		// Leitura do código criptografado da chave
		byte[] wrappedKey = DatatypeConverter.parseHexBinary(valueToDecrypt);

		// Leitura da chave privada 
		CipPrivateKeyReader keyReader = new CipPrivateKeyReader(privateKey);
		PrivateKey PrivKey = (PrivateKey) keyReader.getRSAPrivateKey();

		// Definição do Cipher
		Cipher asymCipher = Cipher.getInstance(PROVIDER_CIPHER);

		// Inicialização do Cipher com a chave privada
		asymCipher.init(Cipher.UNWRAP_MODE, PrivKey);

		// Descriptografar a chave
		Key key = asymCipher.unwrap(wrappedKey, ALGORITHM_CIPHER, Cipher.SECRET_KEY);

		// Retornar a chave descriptografada
		return DatatypeConverter.printHexBinary(key.getEncoded());
	}

	// Gera o hash do dados do arquivo
	public static String signHashSHA256(String valueToEncrypt, String privateKey) throws Exception {

		CipPrivateKeyReader keyReader = new CipPrivateKeyReader(privateKey);
		RSAPrivateKey key = (RSAPrivateKey) keyReader.getRSAPrivateKey();

		// Leitura do hexa a ser assinado
		byte[] byteToEncrypt = DatatypeConverter.parseHexBinary(valueToEncrypt);

		Signature rsa = Signature.getInstance(ALGORITHM_HASH);
		rsa.initSign(key);
		rsa.update(byteToEncrypt);

		// Gerar hash conforme parametrização
		byte[] signature = rsa.sign();

		return DatatypeConverter.printHexBinary( signature );
	}

	public static boolean verifyHashSHA256(String messageText, String signature, String publicKey) throws Exception {

		byte[] publicKeyByteArr = CipBase64.decode(publicKey);
		PublicKey key = KeyFactory.getInstance(ALGORITHM_CHAVE).generatePublic(new X509EncodedKeySpec(publicKeyByteArr));

		byte[] messageByte = DatatypeConverter.parseHexBinary(messageText); 

		Signature sig = Signature.getInstance(ALGORITHM_HASH);
		sig.initVerify(key);
		sig.update( messageByte );

		return sig.verify( DatatypeConverter.parseHexBinary(signature) );

	}


	// Gerar chave 3DES de 24 bytes - FOR TESTS
	public static String get3DESKey() throws NoSuchAlgorithmException {

		KeyGenerator keygenerator = KeyGenerator.getInstance("DESede");
		SecretKey chaveDES = keygenerator.generateKey();

		return DatatypeConverter.printHexBinary(chaveDES.getEncoded()) ;

	}

	// Gerar código HASH com base no arquivo XML
	public static String getXmlHash(String strXML) throws Exception  {

		// Leitura do hexa a ser criptografado
		byte[] byteXml = DatatypeConverter.parseHexBinary(strXML);

		MessageDigest md = MessageDigest.getInstance("SHA-256");
		md.update(byteXml);

		return DatatypeConverter.printHexBinary(md.digest());
	}

}
/
