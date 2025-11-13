<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // DB settings - update if needed
    String jdbcUrl = "jdbc:sqlserver://localhost:1434;databaseName=student_management;encrypt=false;trustServerCertificate=true";
    String dbUser = "sa";
    String dbPass = "sa";

    // Get id from query string and validate
    String idStr = request.getParameter("id");
    int id = -1;
    if (idStr == null) {
%>
    <!doctype html><html><head><meta charset="UTF-8"><title>Error</title></head><body>
      <p style="color:red;font-weight:bold;">Invalid request: missing student id.</p>
      <p><a href="list_students.jsp">Back to list</a></p>
    </body></html>
<%
        return;
    }

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

    // Query student by id
    String selectSql = "SELECT student_code, full_name, email, major FROM dbo.students WHERE id = ?";
    String studentCode = null, fullName = null, email = null, major = null;
    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    } catch (ClassNotFoundException ce) {
        out.println("<p style='color:red;'>JDBC Driver not found. Put the driver JAR in WEB-INF/lib.</p>");
        log("Driver error: " + ce.getMessage(), ce);
        return;
    }

    try (Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
         PreparedStatement ps = conn.prepareStatement(selectSql)) {
        ps.setInt(1, id);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                studentCode = rs.getString("student_code");
                fullName = rs.getString("full_name");
                email = rs.getString("email");
                major = rs.getString("major");
            } else {
%>
    <html><head><meta charset="UTF-8"><title>Not found</title></head><body>
      <p style="color:red;font-weight:bold;">Student not found.</p>
      <p><a href="list_students.jsp">Back to list</a></p>
    </body></html>
<%
                return;
            }
        }
    } catch (SQLException se) {
        out.println("<p style='color:red;font-weight:bold;'>Database error. Please contact admin.</p>");
        log("SQL error fetching student: " + se.getMessage(), se);
        return;
    }
%>
<html>
<head>
  <meta charset="UTF-8" />
  <title>Edit Student</title>
  <style>
    body{font-family:Arial; padding:16px;}
    label{display:block; margin-top:10px;}
    input[type="text"], input[type="email"]{width:100%; padding:8px; box-sizing:border-box;}
    .buttons{margin-top:12px;}
    .error{color:red; font-weight:bold;}
  </style>
</head>
<body>
  <h2>Edit Student</h2>

  <form action="process_edit.jsp" method="post">
    <!-- student_code readonly -->
    <label>
      Student Code (readonly)
      <input type="text" name="student_code" value="<%= studentCode != null ? studentCode : "" %>" readonly />
    </label>

    <label>
      Full Name (required)
      <input type="text" name="full_name" required maxlength="100" value="<%= fullName != null ? fullName : "" %>" />
    </label>

    <label>
      Email (optional)
      <input type="email" name="email" value="<%= email != null ? email : "" %>" />
    </label>

    <label>
      Major (optional)
      <input type="text" name="major" maxlength="50" value="<%= major != null ? major : "" %>" />
    </label>

    <!-- hidden id -->
    <input type="hidden" name="id" value="<%= id %>" />

    <div class="buttons">
      <input type="submit" value="Update Student" />
      <a href="list_students.jsp">Cancel</a>
    </div>
  </form>

</body>
</html>
