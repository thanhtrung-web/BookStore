package com.bookstore.service;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.Properties;

/**
 * EmailService («external» :EmailService) - Handles sending 6-digit OTP verification emails
 * via Gmail SMTP for UC-01 Register.
 */
public class EmailService {

    private static final String DEFAULT_SMTP_HOST = "smtp.gmail.com";
    private static final String DEFAULT_SMTP_PORT = "587";
    private static final String DEFAULT_FROM_NAME = "BookStore Management System";

    private String smtpHost = DEFAULT_SMTP_HOST;
    private String smtpPort = DEFAULT_SMTP_PORT;
    private String smtpUsername = "";
    private String smtpPassword = "";
    private String fromName = DEFAULT_FROM_NAME;

    public EmailService() {
        loadMailProperties();
    }

    private void loadMailProperties() {
        try (InputStream input = EmailService.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                Properties props = new Properties();
                props.load(input);
                this.smtpHost = props.getProperty("mail.smtp.host", DEFAULT_SMTP_HOST).trim();
                this.smtpPort = props.getProperty("mail.smtp.port", DEFAULT_SMTP_PORT).trim();
                this.smtpUsername = props.getProperty("mail.username", "").trim();
                this.smtpPassword = props.getProperty("mail.password", "").replace(" ", "").trim();
                this.fromName = props.getProperty("mail.from.name", DEFAULT_FROM_NAME).trim();
            }
        } catch (Exception ex) {
            System.err.println("[EmailService] Failed to load mail configuration from db.properties: " + ex.getMessage());
        }
    }

    /**
     * Sends an account activation email containing the 6-digit OTP verification code (UC-01).
     */
    public void sendActivationEmail(String email, String token) throws EmailDeliveryException {
        sendActivationEmail(email, token, null);
    }

    /**
     * Sends an account activation email containing the 6-digit OTP code via Gmail SMTP.
     */
    public void sendActivationEmail(String email, String otpCode, String baseUrl) throws EmailDeliveryException {
        if (email == null || email.trim().isEmpty() || otpCode == null || otpCode.trim().isEmpty()) {
            throw new EmailDeliveryException("Email address and 6-digit verification code are required.");
        }

        String recipientEmail = email.trim();
        String code = otpCode.trim();

        System.out.println();
        System.out.println("=======================================================================");
        System.out.println("  [EmailService] SENDING 6-DIGIT OTP VIA GMAIL SMTP");
        System.out.println("  From    : " + smtpUsername);
        System.out.println("  To      : " + recipientEmail);
        System.out.println("  OTP Code: " + code);
        System.out.println("=======================================================================");
        System.out.println();

        if (smtpUsername.isEmpty() || smtpPassword.isEmpty()) {
            throw new EmailDeliveryException("Gmail SMTP credentials are not configured in db.properties.");
        }

        Properties mailProps = new Properties();
        mailProps.put("mail.smtp.auth", "true");
        mailProps.put("mail.smtp.starttls.enable", "true");
        mailProps.put("mail.smtp.starttls.required", "true");
        mailProps.put("mail.smtp.ssl.protocols", "TLSv1.2");
        mailProps.put("mail.smtp.host", smtpHost);
        mailProps.put("mail.smtp.port", smtpPort);
        mailProps.put("mail.smtp.ssl.trust", smtpHost);
        mailProps.put("mail.smtp.connectiontimeout", "12000");
        mailProps.put("mail.smtp.timeout", "12000");
        mailProps.put("mail.smtp.writetimeout", "12000");

        Session mailSession = Session.getInstance(mailProps, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(smtpUsername, smtpPassword);
            }
        });

        try {
            MimeMessage message = new MimeMessage(mailSession);
            try {
                message.setFrom(new InternetAddress(smtpUsername, fromName, "UTF-8"));
            } catch (UnsupportedEncodingException e) {
                message.setFrom(new InternetAddress(smtpUsername));
            }

            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("[BookStore] Mã xác thực tài khoản của bạn là: " + code, "UTF-8");

            String htmlBody = buildOtpEmailHtml(recipientEmail, code);
            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);
            System.out.println(">>> [EmailService] SUCCESS: Sent 6-digit OTP (" + code + ") to " + recipientEmail);

        } catch (MessagingException ex) {
            System.err.println(">>> [EmailService] ERROR sending OTP email: " + ex.getMessage());
            throw new EmailDeliveryException(
                    "Failed to send verification code to " + recipientEmail + ". Please verify the Gmail address and try again.",
                    ex
            );
        }
    }

    private String buildOtpEmailHtml(String recipientEmail, String otpCode) {
        return "<div style=\"font-family:'Segoe UI',Arial,sans-serif;max-width:540px;margin:0 auto;padding:28px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:16px;\">"
                + "<div style=\"text-align:center;padding-bottom:18px;border-bottom:1px solid #e2e8f0;\">"
                + "<h2 style=\"margin:0;color:#0d2562;font-size:22px;\">📚 BookStore Management System</h2>"
                + "<p style=\"margin:4px 0 0;color:#64748b;font-size:12px;\">Read More • Grow More</p>"
                + "</div>"
                + "<div style=\"padding:24px 12px;text-align:center;\">"
                + "<h3 style=\"margin:0 0 10px;color:#0f172a;font-size:18px;\">Xác thực địa chỉ Gmail của bạn</h3>"
                + "<p style=\"margin:0 0 20px;color:#475569;font-size:14px;line-height:1.6;\">"
                + "Xin chào <strong>" + recipientEmail + "</strong>,<br>"
                + "Vui lòng nhập mã xác thực gồm <strong>6 chữ số</strong> dưới đây vào màn hình đăng ký để kích hoạt tài khoản Buyer của bạn:"
                + "</p>"
                + "<div style=\"display:inline-block;padding:16px 34px;background:#0d2562;color:#ffffff;font-size:30px;font-weight:800;letter-spacing:10px;border-radius:12px;margin:8px 0 20px;\">"
                + otpCode
                + "</div>"
                + "<p style=\"margin:0;color:#64748b;font-size:12px;\">"
                + "Nếu bạn không thực hiện yêu cầu đăng ký này, vui lòng bỏ qua email này."
                + "</p>"
                + "</div>"
                + "<div style=\"border-top:1px solid #e2e8f0;padding-top:14px;text-align:center;color:#94a3b8;font-size:11px;\">"
                + "&copy; 2026 BookStore Management System - SWD392 Team PS06"
                + "</div>"
                + "</div>";
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
