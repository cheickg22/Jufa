package ml.jufa.backend.common.exception;

import lombok.Getter;

@Getter
public class JufaException extends RuntimeException {
    
    private final String code;
    private final Object details;
    
    public JufaException(String code, String message) {
        super(message);
        this.code = code;
        this.details = null;
    }
    
    public JufaException(String code, String message, Object details) {
        super(message);
        this.code = code;
        this.details = details;
    }
}
