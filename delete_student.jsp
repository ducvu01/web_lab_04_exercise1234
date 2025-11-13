<%@ page import="java.sql.*, java.net.URLEncoder" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");

    // DB settings
    String jdbcUrl = "jdbc:sqlserver://localhost:1434;databaseName=student_management;encrypt=false;trustServerCertificate=true";
    String dbUser = "sa";
    String dbPass = "sa";

    // Get id from URL
    String idStr = request.getParameter("id");
    if (idStr == null) {
%>
    <!doctype html><html><head><meta charset="UTF-8"><title>Error</title></head><body>
      <p style="color:red;font-weight:bold;">Invalid request: missing student id.</p>
      <p><a href="list_students.jsp">Back to list</a></p>
    </body></html>
<%
        return;
    }

    int id = -1;
    try {
        id = Integer.parseInt(idStr);
    } catch (NumberFormatException nfe) {
%>
    <html><head><meta charset="UTF-8"><title>Error</title></head><body>
      <p style="color:red;font-weight:bold;">Invalid student id.</p>
      <p><a href="list_students.jsp">Back to list</a></p>
    </body></html>
<%
        return;
    }

    // Delete student from DB
    String deleteSql = "DELETE FROM dbo.students WHERE id = ?";

    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    } catch (ClassNotFoundException ce) {
        out.println("<p style='color:red;'>JDBC Driver not found. Put driver JAR in WEB-INF/lib.</p>");
        log("Driver error: " + ce.getMessage(), ce);
        return;
    }

    try (Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
         PreparedStatement ps = conn.prepareStatement(deleteSql)) {

        ps.setInt(1, id);
        int affected = ps.executeUpdate();

        if (affected > 0) {
            String msg = URLEncoder.encode("Student deleted successfully", "UTF-8");
            response.sendRedirect("list_students.jsp?msg=" + msg);
            return;
        } else {
            // ID not found
            out.println("<p style='color:red;font-weight:bold;'>Delete failed: student not found.</p>");
            out.println("<p><a href='list_students.jsp'>Back to list</a></p>");
            return;
        }

    } catch (SQLException se) {
        out.println("<p style='color:red;font-weight:bold;'>Database error. Please contact admin.</p>");
        log("SQL error deleting student: " + se.getMessage(), se);
    }
%>
