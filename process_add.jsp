<%@ page import="java.sql.*, java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // Make sure request encoding is correct
    request.setCharacterEncoding("UTF-8");

    // ========== DB settings - change to match your environment ==========
    String jdbcUrl = "jdbc:sqlserver://localhost:1434;databaseName=student_management;encrypt=false;trustServerCertificate=true";
    String dbUser = "sa";
    String dbPass = "sa";
    // ===================================================================

    // Retrieve and trim parameters
    String studentCode = request.getParameter("student_code");
    String fullName    = request.getParameter("full_name");
    String email       = request.getParameter("email");
    String major       = request.getParameter("major");

    if (studentCode != null) studentCode = studentCode.trim();
    if (fullName != null) fullName = fullName.trim();
    if (email != null) email = email.trim();
    if (major != null) major = major.trim();

    // Server-side validation for required fields
    if (studentCode == null || studentCode.isEmpty() || fullName == null || fullName.isEmpty()) {
%>
    <!doctype html>
    <html><head><meta charset="UTF-8"><title>Error</title></head><body>
      <p class="error" style="color:red;font-weight:bold;">Required fields missing: Student Code and Full Name are required.</p>
      <p><a href="add_student.jsp">Back to Add Student</a></p>
    </body></html>
<%
        return;
    }

    // Insert with PreparedStatement to avoid injection and for correct types
    String insertSql = "INSERT INTO dbo.students (student_code, full_name, email, major) VALUES (?, ?, ?, ?)";

    try {
        // Load driver (helpful on some containers/older JDKs)
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    } catch (ClassNotFoundException cnfe) {
        out.println("<p style='color:red;'>JDBC Driver not found. Make sure the Microsoft JDBC JAR is in WEB-INF/lib.</p>");
        log("Driver missing: " + cnfe.getMessage(), cnfe);
        return;
    }

    try (Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
         PreparedStatement ps = conn.prepareStatement(insertSql)) {

        ps.setString(1, studentCode);
        ps.setString(2, fullName);

        if (email == null || email.isEmpty()) {
            ps.setNull(3, Types.VARCHAR);
        } else {
            ps.setString(3, email);
        }

        if (major == null || major.isEmpty()) {
            ps.setNull(4, Types.VARCHAR);
        } else {
            ps.setString(4, major);
        }

        int affected = ps.executeUpdate();
        if (affected > 0) {
            // Redirect to list with a success message
            String msg = URLEncoder.encode("Student added successfully", "UTF-8");
            response.sendRedirect("list_students.jsp?msg=" + msg);
            return;
        } else {
            out.println("<p style='color:red;'>Insert failed: no rows affected.</p>");
            out.println("<p><a href='add_student.jsp'>Back to Add Student</a></p>");
            return;
        }

    } catch (SQLException ex) {
        // SQL Server duplicate-key errors: 2627 (primary key/unique), 2601 (unique index)
        int sqlCode = ex.getErrorCode();
        if (sqlCode == 2627 || sqlCode == 2601) {
%>
    <html><head><meta charset="UTF-8"><title>Error</title></head><body>
      <p style="color:red;font-weight:bold;">Student code already exists. Please use a different Student Code.</p>
      <p><a href="add_student.jsp">Back to Add Student</a></p>
    </body></html>
<%
        } else {
            // Generic error handling - do not expose details to the user
            out.println("<p style='color:red;font-weight:bold;'>Database error. Please contact the administrator.</p>");
            log("SQL error inserting student: " + ex.getMessage(), ex);
            out.println("<p><a href='add_student.jsp'>Back to Add Student</a></p>");
        }
    }
%>
