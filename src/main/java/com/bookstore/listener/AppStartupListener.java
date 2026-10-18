package com.bookstore.listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * Application Startup Listener.
 * Prints direct clickable URL in the terminal upon server launch.
 */
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        String contextPath = sce.getServletContext().getContextPath();
        System.out.println();
        System.out.println("=======================================================================");
        System.out.println("  [BookStore] Application is READY!");
        System.out.println("  Clickable URL: http://localhost:8080" + contextPath);
        System.out.println("  (Hold Ctrl + Left Click on the link above to open in browser)");
        System.out.println("=======================================================================");
        System.out.println();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[BookStore] Application stopped.");
    }
}
