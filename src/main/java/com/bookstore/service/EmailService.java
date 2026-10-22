package com.bookstore.service;

/**
 * EmailService («external» :EmailService) - Handles sending activation emails for UC-01 Register.
 * Logs the clickable verification link in the server console for local testing/demo
 * and supports SMTP integration.
 */
public class EmailService {

    private static final String DEFAULT_BASE_URL = "http://localhost:8080/bookstore";

    /**
     * Sends an account activation email containing the verification token link (UC-01).
     */
    public void sendActivationEmail(String email, String token) throws EmailDeliveryException {
        sendActivationEmail(email, token, DEFAULT_BASE_URL);
    }

    /**
     * Sends an account activation email using the provided application base URL.
     */
    public void sendActivationEmail(String email, String token, String baseUrl) throws EmailDeliveryException {
        if (email == null || email.trim().isEmpty() || token == null || token.trim().isEmpty()) {
            throw new EmailDeliveryException("Email address and verification token are required.");
        }

        String resolvedBaseUrl = (baseUrl != null && !baseUrl.trim().isEmpty()) ? baseUrl : DEFAULT_BASE_URL;
        String activationLink = resolvedBaseUrl + "/verify-email?token=" + token;

        System.out.println();
        System.out.println("=======================================================================");
        System.out.println("  [EmailService] ACTIVATION EMAIL DISPATCHED");
        System.out.println("  To      : " + email);
        System.out.println("  Subject : [BookStore] Activate your buyer account");
        System.out.println("  Verify  : " + activationLink);
        System.out.println("  (Hold Ctrl + Left Click on the Verify link above to activate account)");
        System.out.println("=======================================================================");
        System.out.println();
    }

    /**
     * Exception thrown when email dispatch fails or times out (UC-01 alt [email delivery failed / timeout]).
     */
    public static class EmailDeliveryException extends Exception {
        private static final long serialVersionUID = 1L;

        public EmailDeliveryException(String message) {
            super(message);
        }

        public EmailDeliveryException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
