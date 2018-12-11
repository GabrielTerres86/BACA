create or replace and compile java source named cecred."CipPrivateKeyReader" as
import java.io.BufferedReader;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.spec.KeySpec;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.RSAPrivateCrtKeySpec;

import javax.xml.bind.DatatypeConverter;


/**
 * Class for reading RSA private key from PEM file. It uses
 * the JMeter FileServer to find the file. So the file should 
 * be located in the same directory as the test plan if the 
 * path is relative.
 * 
 * <p/>There is a cache so each file is only read once. If file
 * is changed, it will not take effect until the program 
 * restarts.
 * 
 * <p/>It can read PEM files with PKCS#8 or PKCS#1 encodings.
 * It doesn't support encrypted PEM files.
 * 
 */
public class CipPrivateKeyReader {

  // Private key file using PKCS #1 encoding
  public static final String P1_BEGIN_MARKER 
    = "-----BEGIN RSA PRIVATE KEY"; //$NON-NLS-1$
  public static final String P1_END_MARKER
      = "-----END RSA PRIVATE KEY"; //$NON-NLS-1$

  // Private key file using PKCS #8 encoding
  public static final String P8_BEGIN_MARKER 
    = "-----BEGIN PRIVATE KEY"; //$NON-NLS-1$
  public static final String P8_END_MARKER
      = "-----END PRIVATE KEY"; //$NON-NLS-1$

  protected final String textKey;

  /**
   * Create a PEM private key file reader.
   * 
   * @param fileName The name of the PEM file
   */
  public CipPrivateKeyReader(String textKey) {
    this.textKey = textKey;
  }

  /**
   * Get a Private Key for the file.
   * 
   * @return Private key
   * @throws IOException
   */

  public PrivateKey getPrivateKey() throws IOException, GeneralSecurityException 
  {
    PrivateKey key = null;
    /*FileInputStream fis = null;*/
    boolean isRSAKey = false;
    //try {
        //File f = new File(fileName);
        //fis = new FileInputStream(f);

        Reader inputString = new StringReader(this.textKey);
        BufferedReader br = new BufferedReader(inputString);
        
        StringBuilder builder = new StringBuilder();
        
        boolean inKey = false;
        
        for (String line = br.readLine(); line != null; line = br.readLine()) {
            if (!inKey) {
                if (line.startsWith("-----BEGIN ") && 
                        line.endsWith(" PRIVATE KEY-----")) {
                    inKey = true;
                    isRSAKey = line.contains("RSA");
                }
                continue;
            }
            else {
                if (line.startsWith("-----END ") && 
                        line.endsWith(" PRIVATE KEY-----")) {
                    inKey = false;
                    isRSAKey = line.contains("RSA");
                    break;
                }
                builder.append(line);
            }
        }
        
        KeySpec keySpec = null;
        byte[] encoded = DatatypeConverter.parseBase64Binary(builder.toString());          
        if (isRSAKey)
        {
          keySpec = getRSAKeySpec(encoded);
        }
        else
        {
          keySpec = new PKCS8EncodedKeySpec(encoded);
        }
        KeyFactory kf = KeyFactory.getInstance("RSA");
        key = kf.generatePrivate(keySpec);

    return key;
  }
 
  public PrivateKey getRSAPrivateKey() throws IOException, GeneralSecurityException 
  {
    PrivateKey key = null;
            
    KeySpec keySpec = null;
    byte[] encoded = DatatypeConverter.parseBase64Binary(this.textKey);          

    keySpec = getRSAKeySpec(encoded);

    KeyFactory kf = KeyFactory.getInstance("RSA");
    key = kf.generatePrivate(keySpec);

    return key;
  }

    /**
     * Convert PKCS#1 encoded private key into RSAPrivateCrtKeySpec.
     * 
     * <p/>The ASN.1 syntax for the private key with CRT is
     * 
     * <pre>
     * -- 
     * -- Representation of RSA private key with information for the CRT algorithm.
     * --
   * RSAPrivateKey ::= SEQUENCE {
     *   version           Version, 
     *   modulus           INTEGER,  -- n
     *   publicExponent    INTEGER,  -- e
     *   privateExponent   INTEGER,  -- d
     *   prime1            INTEGER,  -- p
     *   prime2            INTEGER,  -- q
     *   exponent1         INTEGER,  -- d mod (p-1)
     *   exponent2         INTEGER,  -- d mod (q-1) 
     *   coefficient       INTEGER,  -- (inverse of q) mod p
     *   otherPrimeInfos   OtherPrimeInfos OPTIONAL 
     * }
     * </pre>
     * 
     * @param keyBytes PKCS#1 encoded key
     * @return KeySpec
     * @throws IOException
     */

    private RSAPrivateCrtKeySpec getRSAKeySpec(byte[] keyBytes) throws IOException  {

      CipDerParser parser = new CipDerParser(keyBytes);

      CipAsn1Object sequence = parser.read();
        if (sequence.getType() != CipDerParser.SEQUENCE)
          throw new IOException("Invalid DER: not a sequence"); //$NON-NLS-1$

        // Parse inside the sequence
        parser = sequence.getParser();

        parser.read(); // Skip version
        BigInteger modulus = parser.read().getInteger();
        BigInteger publicExp = parser.read().getInteger();
        BigInteger privateExp = parser.read().getInteger();
        BigInteger prime1 = parser.read().getInteger();
        BigInteger prime2 = parser.read().getInteger();
        BigInteger exp1 = parser.read().getInteger();
        BigInteger exp2 = parser.read().getInteger();
        BigInteger crtCoef = parser.read().getInteger();

        RSAPrivateCrtKeySpec keySpec = new RSAPrivateCrtKeySpec(
            modulus, publicExp, privateExp, prime1, prime2,
            exp1, exp2, crtCoef);

        return keySpec;
    }    
}
/
